# class KnowledgeBase < ApplicationRecord
#   belongs_to :user
#   has_many :files
# end
class KnowledgeBase < ApplicationRecord
  has_many :files, dependent: :destroy
  belongs_to :user
  validates :name, presence: true
end
