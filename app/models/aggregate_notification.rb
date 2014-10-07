# == Schema Information
#
# Table name: aggregate_notifications
#
#  id          :integer          not null, primary key
#  click_count :integer          default(0)
#  score       :integer          default(0)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class AggregateNotification < OpenCongressModel

  #========== FILTERS

  # touched when new child notification is created
  after_touch -> { email_notification if email_conditions_met? }

  #========== RELATIONS

  #----- HAS MANY

  has_many :notifications
  has_many :activities, :class_name => 'PublicActivity::Activity', :through => :notifications

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
  # @return [AggregateNotification, nil] the instance of nil
  def self.create_from_activity(activity_id, user_id)

    activity = PublicActivity::Activity.find(activity_id)

    if activity.present?

      # TODO: optimize this with database indexes
      # check if an aggregate notification already exists for this activity
      an = User.find(user_id).aggregate_notifications.where('activities.owner_id'=>activity.owner_id,
                                                            'activities.owner_type'=>activity.owner_type,
                                                            'activities.key'=>activity.key).last

      # TODO: determine whether to generate new aggregate notification based on user notification settings

      # create new aggregate notification if user settings calls for it
      an = AggregateNotification.create(user_id:user_id) if an.nil?
      Notification.create(activities_id:activity.id, aggregate_notification_id:an.id)

      return an

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

  private

  def email_notification
    NotificationEmail.create(aggregate_notification_id:self.id)
  end

  def email_conditions_met?
    usn = user.notification_settings(activity_key)

    return true if notifications.count >= usn.threshold
    # TODO: determine other conditions for notification settings
    # condition 2...
    # condition 3...
    # condition 4...

    return false

  end

end