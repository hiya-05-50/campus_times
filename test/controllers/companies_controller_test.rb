require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(name: "Massive Dynamic", industry: "Tech", contact_email: "recruiter@massive.test")
    @admin = User.create!(name: "Nina Sharp", email: "nina@example.com", role: "admin")
    @student = User.create!(name: "Peter Bishop", email: "peter@example.com", role: "student")
  end

  test "can view companies index" do
    get companies_path, headers: { "X-User-Id" => @student.id.to_s }
    assert_response :success
    assert_select "h1", text: /Partner Companies/i
    assert_select ".company-title", text: "Massive Dynamic"
  end

  test "can view company details" do
    get company_path(@company), headers: { "X-User-Id" => @student.id.to_s }
    assert_response :success
    assert_select "h1", text: "Massive Dynamic"
  end

  test "admin can create company" do
    assert_difference("Company.count", 1) do
      post companies_path,
           headers: { "X-User-Id" => @admin.id.to_s },
           params: {
             company: {
               name: "Wayne Enterprises",
               industry: "Defense & Tech",
               contact_email: "lucius@wayne.test"
             }
           }
    end
    assert_redirected_to company_path(Company.last)
  end

  test "student cannot create company" do
    assert_no_difference("Company.count") do
      post companies_path,
           headers: { "X-User-Id" => @student.id.to_s },
           params: {
             company: { name: "Unauthorized Co" }
           }
    end
    assert_redirected_to placement_drives_path
  end
end
