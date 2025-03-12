# https://ai.plainenglish.io/building-your-own-local-rag-system-with-llama2-ollama-and-langchain-using-custom-data-a-d4909b74f450

from langchain_community.document_loaders import Docx2txtLoader
import os

def load_docx_files(directory_path):
    documents = []
    for root, dirs, files in os.walk(directory_path):
        for file in files:
            if file.endswith('.docx'):
                file_path = os.path.join(root, file)
                print( file )
                loader = Docx2txtLoader(file_path)
                documents.extend(loader.load())
    return documents

# Load documents from a directory
books = load_docx_files("docs")


from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=0
)
all_splits = text_splitter.split_documents(books)


from langchain_chroma import Chroma
from langchain_community.embeddings import OllamaEmbeddings

vectorstore = Chroma.from_documents(
    documents=all_splits,
    embedding=OllamaEmbeddings(model="llama2:7b-chat-q8_0", show_progress=True),
    persist_directory="./database/chroma_db1",
)

