use async_openai::{config::OpenAIConfig, types::CreateCompletionRequestArgs, Client};
use futures::StreamExt;
use hyper::{
    body::{Body, Bytes},
    Response,
};
use lambda_runtime::{service_fn, Error, LambdaEvent};
use serde::Deserialize;
use std::env;

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .with_target(false)
        .without_time()
        .init();

    lambda_runtime::run_with_streaming_response(service_fn(func)).await?;
    Ok(())
}

#[derive(Deserialize)]
struct Request {
    body: String,
}

async fn func(event: LambdaEvent<Request>) -> anyhow::Result<Response<Body>> {
    let message = event.payload.body;
    let request = CreateCompletionRequestArgs::default()
        .model("text-davinci-003")
        .n(1)
        .prompt(message)
        .stream(true)
        .max_tokens(1024_u16)
        .build()?;

    let (mut tx, rx) = Body::channel();

    tokio::spawn(async move {
        let config = OpenAIConfig::new()
            .with_api_key(env::var("OPENAI_API_KEY").expect("No API key found"))
            .with_org_id(env::var("OPENAI_ORG_ID").expect("No org id found"));
        let client = Client::with_config(config);
        let mut stream = client.completions().create_stream(request).await.unwrap();
        while let Some(response) = stream.next().await {
            let ccr = response.unwrap();
            let chunk: Bytes = ccr.choices[0].text.clone().into();
            tx.send_data(chunk).await.unwrap();
        }
    });

    let resp = Response::builder()
        .header("content-type", "text/html")
        .body(rx)?;

    Ok(resp)
}
