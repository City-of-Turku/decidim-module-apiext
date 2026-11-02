# frozen_string_literal: true

shared_examples "update project mutation examples" do
  it "updates the project" do
    expect { response }.not_to change(Decidim::Budgets::Project, :count)

    expect(response["updateProject"]).to eq("id" => project.id.to_s)
    project.reload

    expect(project.title["en"]).to match(attributes[:title][:en])
    expect(project.description["en"]).to match(attributes[:description][:en])
    expect(project.budget_amount).to eq(attributes[:budgetAmount])
    expect(project.address).to eq(attributes[:location][:address])
    expect(project.latitude).to eq(attributes[:location][:latitude])
    expect(project.longitude).to eq(attributes[:location][:longitude])
    expect(project.taxonomies).to match_array(taxonomies)
    expect(project.linked_resources(:proposals, "included_proposals").map(&:id)).to match_array(proposals.map(&:id))
  end

  context "when the project has attachments" do
    let!(:first_attachment) do
      create(:attachment, attached_to: project)
    end

    let!(:second_attachment) do
      create(:attachment, attached_to: project)
    end

    context "when all attachment IDs are provided" do
      before do
        attributes[:attachmentIds] = [
          first_attachment.id,
          second_attachment.id
        ]
      end

      it "preserves all existing attachments" do
        expect(response["updateProject"]).to eq("id" => project.id.to_s)

        expect(project.reload.attachments.pluck(:id)).to contain_exactly(
          first_attachment.id,
          second_attachment.id
        )
      end
    end

    context "when only one attachment ID is provided" do
      before do
        attributes[:attachmentIds] = [first_attachment.id]
      end

      it "preserves the specified attachment and deletes the other" do
        expect(response["updateProject"]).to eq("id" => project.id.to_s)

        expect(project.reload.attachments.pluck(:id)).to contain_exactly(
          first_attachment.id
        )

        expect(Decidim::Attachment.exists?(second_attachment.id)).to be(false)
      end
    end

    context "when an empty attachment list is provided" do
      before do
        attributes[:attachmentIds] = []
      end

      it "deletes all existing attachments" do
        expect(response["updateProject"]).to eq("id" => project.id.to_s)

        expect(project.reload.attachments).to be_empty
        expect(Decidim::Attachment.exists?(first_attachment.id)).to be(false)
        expect(Decidim::Attachment.exists?(second_attachment.id)).to be(false)
      end
    end

    context "when attachment IDs are omitted" do
      before do
        attributes.delete(:attachmentIds)
      end

      it "preserves all existing attachments" do
        expect(response["updateProject"]).to eq("id" => project.id.to_s)

        expect(project.reload.attachments.pluck(:id)).to contain_exactly(
          first_attachment.id,
          second_attachment.id
        )

        expect(Decidim::Attachment.exists?(first_attachment.id)).to be(true)
        expect(Decidim::Attachment.exists?(second_attachment.id)).to be(true)
      end
    end
  end
end

shared_examples "create project mutation examples" do
  it "creates the project" do
    expect { response }.to change(Decidim::Budgets::Project, :count).by(1)

    project = Decidim::Budgets::Project.order(:id).last
    expect(response["createProject"]).to eq("id" => project.id.to_s)

    expect(project.title).to match(attributes[:title].stringify_keys)
    expect(project.description).to match(attributes[:description].stringify_keys)
    expect(project.budget_amount).to eq(attributes[:budgetAmount])
    expect(project.address).to eq(attributes[:location][:address])
    expect(project.latitude).to eq(attributes[:location][:latitude])
    expect(project.longitude).to eq(attributes[:location][:longitude])
    expect(project.taxonomies).to match_array(taxonomies)
    expect(project.linked_resources(:proposals, "included_proposals").map(&:id)).to match_array(proposals.map(&:id))
  end
end

shared_examples "soft delete project mutation examples" do
  it "soft deletes the project" do
    expect { response }
      .to change(Decidim::Budgets::Project, :count).by(-1)

    expect(response["softDeleteProject"]).to eq("id" => project.id.to_s)

    expect(project.reload.deleted_at).to be_present
    expect(Decidim::Budgets::Project.unscoped.exists?(project.id)).to be(true)
  end

  it "does not permanently delete the project" do
    expect { response }
      .not_to(change { Decidim::Budgets::Project.unscoped.count })

    expect(project.reload.deleted_at).to be_present
  end
end
