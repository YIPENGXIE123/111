import weaviate
from langchain_core.documents import Document
from langchain_core.retrievers import BaseRetriever

class MyRetriever(BaseRetriever):
    def __init__(self, client, model, class_name, k=30):
        self.client = client
        self.model = model
        self.class_name = class_name
        self.k = k

    def _get_relevant_documents(self, query):
        query_vector = self.model.encode([query])[0].tolist()
        near_vector = {'vector': query_vector}
        response = (
            self.client.query
            .get(self.class_name, ['sentence_id', 'sentence'])
            .with_near_vector(near_vector)
            .with_limit(self.k)
            .with_additional(['distance'])
            .do()
        )
        return [
            Document(page_content=result['sentence'])
            for result in response['data']['Get'][self.class_name]
        ]
