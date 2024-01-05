# frozen_string_literal: true

module Decidim
  module Apiext
    module Budgets
      class BudgetsMutationType < Decidim::Api::Types::BaseObject
        include ::Decidim::Apiext::ApiPermissions

        graphql_name "BudgetsMutation"
        description "Budgets of a component."

        field :budget, type: ::Decidim::Apiext::Budgets::BudgetMutationType, description: "Mutates a budget", null: true do
          argument :id, GraphQL::Types::ID, "The ID of the budget", required: true
        end

        field :create_budget, ::Decidim::Budgets::BudgetType, null: false do
          description "create budget for the currnt budgets component
A typical mutation would be like:

```
  mutation{
    component(id: 123) {
      ... on BudgetsMutation {
        createBudget(
          attributes:{
            title: {fi: 'Your title'},
            description: {fi: 'Your description' },
            wight: 10,
            scope_id: 2,
            total_budget: 12345
          }
        ){
          id
        }
      }
    }
  }
```
          "

          argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true
        end

        field :update_budget, type: ::Decidim::Budgets::BudgetType, description: "Mutates a budget", null: true do
          description "Edit budget.

A typical mutation would be like:

```
  mutation{
    component(id: 123) {
      ... on BudgetsMutation {
          editBudget(
            attributes: {
              title: {en: 'Dummy title'}
            },
            id: 234
          ){
            id
          }
      }
    }
  }
```
"
          argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true
          argument :id, GraphQL::Types::ID, "The ID of the budget", required: true
        end

        field :delete_budget, type: ::Decidim::Budgets::BudgetType, description: "Mutates a budget", null: true do
          description "Delete budget

A typical mutation would be like:

```
  mutation{
    component(id: 123) {
      ... on BudgetsMutation {
        deleteBudget(id: 234){
          id
        }
      }
    }
  }
```
"
          argument :id, GraphQL::Types::ID, "The ID of the budget", required: true
        end

        def budget(id:)
          @budget ||= Decidim::Budgets::Budget.find_by(id: id, component: object)
        end

        def create_budget(attributes:)
          enforce_permission_to :create, :budget

          form = ::Decidim::Budgets::Admin::BudgetForm.from_params(
            weight: attributes.weight,
            title: attributes.title,
            description: attributes.description,
            total_budget: attributes.total_budget.to_i,
            decidim_scope_id: attributes.scope_id.to_i
          ).with_context(
            current_component: object,
            current_organization: object.organization,
            current_user: current_user
          )

          ::Decidim::Budgets::Admin::CreateBudget.call(form) do
            on(:ok, budget) do
              return budget
            end

            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end

            GraphQL::ExecutionError.new(
              I18n.t("decidim.budgets.admin.budgets.create.invalid")
            )
          end
        end

        def update_budget(attributes:, id:)
          enforce_permission_to :update, :budget, budget: budget(id: id)

          form = ::Decidim::Budgets::Admin::BudgetForm.from_params(
            weight: attributes.weight,
            title: attributes.title,
            description: attributes.description,
            total_budget: attributes.total_budget.to_i,
            decidim_scope_id: attributes.scope_id
          ).with_context(
            current_component: object,
            current_organization: object.organization,
            current_user: current_user
          )
          ::Decidim::Budgets::Admin::UpdateBudget.call(form, @budget) do
            on(:ok, budget) do
              return budget
            end

            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end

            GraphQL::ExecutionError.new(
              I18n.t("decidim.budgets.admin.budgets.update.invalid")
            )
          end
        end

        def delete_budget(id:)
          enforce_permission_to :update, :budget, budget: budget(id: id)
          ::Decidim::Budgets::Admin::DestroyBudget.call(@budget, current_user) do
            on(:ok, budget) do
              return budget
            end

            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end

            GraphQL::ExecutionError.new(
              I18n.t("decidim.budgets.admin.budgets.destroy.invalid")
            )
          end
        end
      end
    end
  end
end
