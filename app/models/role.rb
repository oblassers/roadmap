class Role < ActiveRecord::Base
  after_initialize :set_defaults
  include FlagShihTzu

  ##
  # Associationsrequire "role"
  
  belongs_to :user
  belongs_to :plan

  ##
  # Define Bit Field Values
  # Column access
  has_flags 1 => :creator,            # 1
            2 => :administrator,      # 2
            3 => :editor,             # 4
            4 => :commenter,          # 8
            5 => :reviewer,           # 16
            column: 'access'

  validates :user, :plan, :access, presence: {message: _("can't be blank")}
  validates :access, numericality: {greater_than: 0, message: _("can't be less than zero")}

  ##
  # return the access level for the current project group
  # 5 if the user is a reviewer
  # 3 if the user is an administrator
  # 2 if the user is an editor
  # 1 if the user can only read
  # used to facilliatte formtastic
  #
  # @return [Integer]
  def access_level
    if self.reviewer?
      return 5
    elsif self.administrator?
      return 3
    elsif self.editor?
      return 2
    elsif self.commenter?
      return 1
    end
  end

  # Sets access_level according to bit fields defined in the column access
  # TODO refactor according to the hash defined above (e.g. 1 key is :creator, 2 key is :administrator, etc)
  def set_access_level(access_level)
    if access_level >= 1
      self.commenter = true
    else
      self.commenter = false
    end
    if access_level >= 2
      self.editor = true
    else
      self.editor = false
    end
    if access_level >= 3
      self.administrator = true
    else
      self.administrator = false
    end
  end

  # Returns a hash of hashes where each key represents an access level (e.g. see access_level method to understand the integers)
  # This method becomes useful for generating template messages (e.g. permissions change notification mailer)
  def self.access_level_messages
    {
      5 => {
        :type => _('reviewer'),
        :placeholder1 => _('read the plan and provide feedback.'),
        :placeholder2 => nil
        },
      3 => {
        :type => _('co-owner'),
        :placeholder1 => _('write and edit the plan in a collaborative manner.'),
        :placeholder2 => _('You can also grant rights to other collaborators.')
        },
      2 => {
        :type => _('editor'),
        :placeholder1 => _('write and edit the plan in a collaborative manner.'),
        :placeholder2 => nil,
        },
      1 => {
        :type => _('read-only'),
        :placeholder1 => _('read the plan and leave comments.'),
        :placeholder2 => nil,
      }
    }
  end

  def set_defaults
    self.active = true if self.new_record?
  end

end

# -----------------------------------------------------
# Bitwise key
# -----------------------------------------------------
# 01 - creator
# 02 - administrator
# 03 - creator + administrator
# 04 - editor
# 05 - creator + editor
# 06 - administraor + editor
# 07 - creator + editor + administrator
# 08 - commenter
# 09 - creator + commenter
# 10 - administrator + commenter
# 11 - creator + administrator + commenter
# 12 - editor + commenter
# 13 - creator + editor + commenter
# 14 - administrator + editor + commenter
# 15 - creator + administrator + editor + commenter
# 16 - reviewer
# 17 - creator + reviewer
# 18 - administrator + reviewer
# 19 - creator + administrator + reviewer
# 20 - editor + reviewer
# 21 - creator + editor + reviewer
# 22 - administraor + editor + reviewer
# 23 - creator + editor + administrator + reviewer
# 24 - commenter + reviewer
# 25 - creator + commenter + reviewer
# 26 - administrator + commenter + reviewer
# 27 - creator + administrator + commenter + reviewer
# 28 - editor + commenter + reviewer
# 29 - creator + editor + commenter + reviewer
# 30 - administrator + editor + commenter + reviewer
# 31 - creator + administrator + editor + commenter + reviewer