use std::env;

use anyhow::Ok;
use async_openai::{config::OpenAIConfig, types::CreateCompletionRequestArgs, Client};
use aws_config::{meta::region::RegionProviderChain, BehaviorVersion, Region};
use aws_sdk_apigatewaymanagement::{config, primitives::Blob};
use futures::StreamExt;
use lambda_http::{
    aws_lambda_events::apigw::{ApiGatewayProxyResponse, ApiGatewayWebsocketProxyRequest},
    lambda_runtime::{run, LambdaEvent},
    service_fn, Error,
};

#[tracing::instrument(skip(event))]
async fn handler(
    event: LambdaEvent<ApiGatewayWebsocketProxyRequest>,
) -> anyhow::Result<ApiGatewayProxyResponse> {
    let event_type = event.payload.request_context.event_type.clone();
    match event_type.as_deref() {
        Some("CONNECT") => {
            tracing::info!("CONNECT");
        }
        Some("MESSAGE") => {
            tracing::info!("MESSAGE");

            let message = event.payload.body.clone();

            let config = OpenAIConfig::new()
                .with_api_key(env::var("OPENAI_API_KEY").expect("No API key found"))
                .with_org_id(env::var("OPENAI_ORG_ID").expect("No org id found"));
            let client = Client::with_config(config);
            let request = CreateCompletionRequestArgs::default()
                .model("text-davinci-003")
                .n(1)
                .prompt(message.expect("No message found"))
                .stream(true)
                .max_tokens(1024_u16)
                .build()?;
            let mut stream = client.completions().create_stream(request).await?;

            let region = "ap-northeast-1";
            let region_provider = RegionProviderChain::first_try(Region::new(region));
            let shared_config = aws_config::defaults(BehaviorVersion::v2023_11_09())
                .region(region_provider)
                .load()
                .await;
            let apigw_id = env::var("APIGW_ID").expect("No APIGW_ID found");
            let api_uri =
                format!("https://{apigw_id}.execute-api.ap-northeast-1.amazonaws.com/prod");
            let api_management_config = config::Builder::from(&shared_config)
                .endpoint_url(api_uri)
                .build();
            let apigw_client =
                aws_sdk_apigatewaymanagement::Client::from_conf(api_management_config);

            let connection_id = &event
                .payload
                .request_context
                .connection_id
                .clone()
                .expect("No connection ID found");

            while let Some(response) = stream.next().await {
                let ccr = response?;
                let blob = Blob::new(
                    serde_json::to_vec(&ccr.choices[0].text.clone()).expect("Could not serialize"),
                );

                apigw_client
                    .post_to_connection()
                    .connection_id(connection_id)
                    .data(blob)
                    .send()
                    .await?;
            }
        }
        Some("DISCONNECT") => {
            tracing::info!("DISCONNECT event");
        }
        Some(s) => {
            tracing::error!("Unknown event type: {:?}", s);
        }
        None => {
            tracing::error!("No event type found");
        }
    }

    Ok(ApiGatewayProxyResponse {
        status_code: 200,
        ..Default::default()
    })
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .with_target(false)
        .without_time()
        .init();
    run(service_fn(handler)).await
}
