# == Schema Information
#
# Table name: facebook_user_bills
#
#  id               :integer          not null, primary key
#  facebook_user_id :integer
#  bill_id          :integer
#  tracking_type    :string(255)
#  comment          :text
#  updated_at       :datetime
#  created_at       :datetime
#

class FacebookUserBill < OpenCongressModel
  belongs_to :facebook_user
  belongs_to :bill
  
  validates_uniqueness_of :bill_id, :scope => :facebook_user_id, :message => "This bill is already on your profile!"

  @@TRACKING_TYPES = {
    "watching" => 'Just Following',
    "pass" => 'Want To Pass',
    "fail" => "Don't Want To Pass"
  }
  
  @@TRACKING_ACTION_TYPES = {
    "watching" => 'tracking',
    "pass" => 'supporting',
    "fail" => 'against'
  }
  
  def FacebookUserBill.text_for_tracking_type(ttype)
    @@TRACKING_TYPES[ttype]
  end
  
  def action_for_tracking_type
    @@TRACKING_ACTION_TYPES[self.tracking_type]
  end
  
  def FacebookUserBill.tracking_types
    @@TRACKING_TYPES
  end
end
