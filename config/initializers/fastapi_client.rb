require 'rest-client'

class FastapiClient
  BASE_URL = 'http://127.0.0.1:8002'

  def self.retrieve_documents(question, class_name)
    response = RestClient.post("#{BASE_URL}/retrieve", {
      question: question,
      class_name: class_name
    }.to_json, { content_type: :json })
    JSON.parse(response.body)["documents"]
  end

  def self.generate_answer(question, context)
    response = RestClient.post("#{BASE_URL}/generate", {
      question: question,
      context: context
    }.to_json, { content_type: :json })
    JSON.parse(response.body)["answer"]
  end
end
