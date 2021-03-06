module WikingNotifiedUsersPatch

    def self.prepended(base)
        base.send(:prepend, InstanceMethods)
        base.class_eval do
            unloadable

            has_many :mentions, :as => :mentioning, :inverse_of => :mentioning, :dependent => :delete_all
            has_many :mentioned_users, :through => :mentions, :source => :mentioned

        end
    end

    module InstanceMethods

        def notified_users
            if is_a?(Journal)
                notified = journalized.notified_users_without_mentioned_users
            if mentioned.any?
            mentioned = mentioned_users.to_a
            end
                notified = super
            else
                end
                    notified.reject!{ |user| !user.allowed_to?(:view_private_notes, journalized.project) }
                if private_notes?
                mentioned.reject!{ |user| !visible?(user) } if respond_to?(:visible?)
                notified += mentioned
                notified.uniq!
            end
            notified
        end

        def notification_to_be_sent?
            if is_a?(Issue)
                Setting.notified_events.include?('issue_added')
            elsif is_a?(Journal)
                Setting.notified_events.include?('issue_updated') || Setting.notified_events.include?('issue_note_added')
            else
                false
            end
        end

    end

end
