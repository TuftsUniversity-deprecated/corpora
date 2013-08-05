require 'spec_helper'

describe "features/edit" do
  before(:each) do
    @feature = assign(:feature, stub_model(Feature,
      :type => "",
      :name => "MyString",
      :description => "MyString",
      :link => "MyString"
    ))
  end

  it "renders the edit feature form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", feature_path(@feature), "post" do
      assert_select "input#feature_type[name=?]", "feature[type]"
      assert_select "input#feature_name[name=?]", "feature[name]"
      assert_select "input#feature_description[name=?]", "feature[description]"
      assert_select "input#feature_link[name=?]", "feature[link]"
    end
  end
end
