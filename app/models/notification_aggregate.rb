# == Schema Information
#
# Table name: notification_aggregates
#
#  id          :integer          not null, primary key
#  score       :integer          default(0)
#  hide        :integer          default(0)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  click_count :integer          default(0)
#

class NotificationAggregate < OpenCongressModel

  #========== FILTERS

  # touched when new child notification item is created
  after_touch -> { NotificationDistributor.initiate_distribution(self) }

  #========== RELATIONS

  #----- HAS MANY

  has_many :notification_items
  has_many :notification_distributors
  has_many :activities, :class_name => 'PublicActivity::Activity', :through => :notification_items

  #----- BELONGS TO

  belongs_to :user

  #========== ALIASES

  alias :recipient :user

  #========== METHODS

  #----- CLASS

  # Factory for aggregate notification creation for when public activity generates activity.
  #
  # @param activity_id [Integer] PublicActivity::Activity id value
  # @param user_id [Integer] User id value
  # @return [AggregateNotification, nil] an instance of nil
  def self.create_from_activity(activity_id, user_id)

    activity = PublicActivity::Activity.find(activity_id)

    if activity.present?

      user = User.find(user_id)

      # TODO: optimize this with database indexes
      # check if an aggregate notification already exists for this activity
      na = user.notification_aggregates.where('activities.owner_id'=>activity.owner_id,
                                              'activities.owner_type'=>activity.owner_type,
                                              'activities.key'=>activity.key).last

      # get user's settings for this particular activity and item based on their bookmark
      na_options = user.notification_option_item(na.activity_key, na.bookmark)
      # create new aggregate notification if user settings calls for it
      na = NotificationAggregate.create(user_id:user_id, updated_at: nil) if na_options.stale_aggregate?(na)
      # create notification item and associated with aggregate notification
      NotificationItem.create(activities_id:activity.id, notification_aggregate_id:na.id)

      return na

    else
      return nil
    end
  end

  #----- INSTANCE

  public

  def activity_owner
    activities.first.owner if activities.any?
  end

  def activity_key
    activities.first.key if activities.any?
  end

  def bookmark
    ao = activity_owner
    Bookmark.where(bookmarkable_id:ao.id, bookmarkable_type: ao.class.name, user_id: self.user_id).first
  end

end