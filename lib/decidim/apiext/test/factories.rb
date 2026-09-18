# frozen_string_literal: true


FactoryBot.modify do
  # Fix comments specs for testing the fix for this bug:
  # https://github.com/decidim/decidim/pull/15170
  factory :comment do
    author { build(:user, :confirmed, organization: commentable.organization, skip_injection:) }
  end
end