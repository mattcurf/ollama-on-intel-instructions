from langchain_community.llms import Ollama

# Initialize Ollama with your chosen model
llm = Ollama(model="llama2:7b")

# Invoke the model with a query
response = llm.invoke("What is LLM?")
print(response)
