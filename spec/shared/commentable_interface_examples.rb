# frozen_string_literal: true

require "spec_helper"

shared_examples_for "commentable interface" do
  describe "total_comments_count" do
    let(:query) { "{ totalCommentsCount }" }

    it "includes the field" do
      expect(response["totalCommentsCount"]).to eq(model.comments_count)
    end
  end

  describe "with comments" do
    let(:comments) { create_list(:comment, 5, commentable: model) }
    let(:subcomments_first_level) do
      comments.map do |comment|
        create_list(:comment, 2, commentable: comment)
      end.flatten
    end
    let!(:subcomments_second_level) do
      subcomments_first_level.map do |comment|
        create(:comment, commentable: comment)
      end
    end

    let(:query) do
      %(
        {
          comments {
            ...dataFragment
            comments {
              ...dataFragment
              comments {
                ...dataFragment
              }
            }
          }
        }
        fragment dataFragment on Comment {
          id
          body
          createdAt
          author { name }
        }
      )
    end

    it "includes the comments" do
      expect(response["comments"]).to be_a(Array)
      expect(response["comments"].count).to eq(5)

      response["comments"].each do |comment|
        expect(comment["comments"]).to be_a(Array)
        expect(comment["comments"].count).to eq(2)

        subcomments = subcomments_first_level.select { |c| c.commentable.id == comment["id"].to_i }
        expect(comment["comments"].map { |c| c["id"].to_i }).to match_array(subcomments.map(&:id))

        comment["comments"].each do |subcomment|
          expect(subcomment["comments"]).to be_a(Array)
          expect(subcomment["comments"].count).to eq(1)

          subcomments2 = subcomments_second_level.select { |c| c.commentable.id == subcomment["id"].to_i }
          expect(subcomment["comments"].map { |c| c["id"].to_i }).to match_array(subcomments2.map(&:id))
        end
      end
    end
  end
end
