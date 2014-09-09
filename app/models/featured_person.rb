# == Schema Information
#
# Table name: featured_people
#
#  id         :integer          not null, primary key
#  person_id  :integer
#  text       :text
#  updated_at :datetime
#  created_at :datetime
#

class FeaturedPerson < OpenCongressModel
  self.table_name = 'featured_people'
  
  belongs_to :person
  
  validates_presence_of :person, :text
  
  def FeaturedPerson.senator
    find(:first, :include => :person, :conditions => "people.title='Sen.'", 
         :order => 'featured_people.created_at DESC');
  end

  def FeaturedPerson.representative
    find(:first, :include => :person, :conditions => "people.title='Rep.'", 
         :order => 'featured_people.created_at DESC');
  end
  
  def atom_id_as_entry
    "tag:opencongress.org,#{created_at.strftime("%Y-%m-%d")}:/person/featured/#{id}"
  end
end
