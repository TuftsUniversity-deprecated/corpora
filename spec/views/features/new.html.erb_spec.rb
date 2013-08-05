require 'spec_helper'

describe "features/new" do
  before(:each) do
    assign(:feature, stub_model(Feature,
      :type => "",
      :name => "MyString",
      :description => "MyString",
      :link => "MyString"
    ).as_new_record)
  end

  it "renders new feature form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", features_path, "post" do
      assert_select "input#feature_type[name=?]", "feature[type]"
      assert_select "input#feature_name[name=?]", "feature[name]"
      assert_select "input#feature_description[name=?]", "feature[description]"
      assert_select "input#feature_link[name=?]", "feature[link]"
    end
  end
end
