class Project < ApplicationRecord
  belongs_to :tenant

  validates_uniqueness_of :title
  validates_presence_of :title, :details, :expected_completion_date
  validate :free_plan_can_only_have_one_project
  has_many :artifacts, dependent: :destroy
  has_many :user_projects
  has_many :users, through: :user_projects

  def free_plan_can_only_have_one_project
    organization = tenant
    if (self.new_record?) && (organization.plan == "free") && (tenant.projects.count == 1)
      errors.add(:base, "Free plans cannot have more than one project")
    end
  end

  def self.by_user_plan_and_tenant(tenant_id, user)
    tenant = user.tenants.find(tenant_id)
    if tenant.plan == 'premium'
      if user.is_admin?
        tenant.projects
      else
        user.projects.where(tenant_id: tenant_id)
      end
    else
      if user.is_admin?
        tenant.projects.order(:id).limit(1)
      else
        user.projects.where(tenant_id: tenant.id).order(:id).limit(1)
      end
    end
  end
end
