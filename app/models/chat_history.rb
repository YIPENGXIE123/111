class ChatHistory < ApplicationRecord
  belongs_to :user
  belongs_to :knowledge_base
end
