from langchain_community.llms import Ollama

# Initialize Ollama with your chosen model
llm = Ollama(model="tinyllama:1.1b-chat-v1-q8_0")

# Invoke the model with a query
response = llm.invoke("What is LLM?")
print(response)
