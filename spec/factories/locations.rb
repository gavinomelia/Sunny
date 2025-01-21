FactoryBot.define do
  factory :location do
    name { "Sample Location" }
    latitude { 35.6895 }
    longitude { 139.6917 }
    association :user
  end
end
