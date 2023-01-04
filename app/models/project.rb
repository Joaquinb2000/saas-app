class Project < ApplicationRecord
  belongs_to :tenant

  validates_uniqueness_of :title
  validates_presence_of :title, :details, :expected_completion_date
  validate :free_plan_can_only_have_one_project
  has_many :artifacts, dependent: :destroy

  def free_plan_can_only_have_one_project
    organization = tenant
    if (self.new_record?) && (organization.plan == "free") && (tenant.projects.count == 1)
      errors.add(:base, "Free plans cannot have more than one project")
    end
  end

  def self.by_user_plan_and_tenant(tenant_id, user)
    tenant = user.tenants.find(tenant_id)
    if tenant.plan == 'premium'
      tenant.projects
    else
      tenant.projects.order(:id).limit(1)
    end
  end
end
