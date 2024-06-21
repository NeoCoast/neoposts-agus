# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Like, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:likeable) }

  subject { build(:like, :likeable_type_post) }
  it 'validates uniqueness of user_id scoped to likeable_type "Post" and likeable_id' do
    expect(subject).to validate_uniqueness_of(:user_id).scoped_to(:likeable_type, :likeable_id)
  end

  subject { build(:like, :likeable_type_comment) }
  it 'validates uniqueness of user_id scoped to likeable_type "Comment" and likeable_id' do
    expect(subject).to validate_uniqueness_of(:user_id).scoped_to(:likeable_type, :likeable_id)
  end
end
