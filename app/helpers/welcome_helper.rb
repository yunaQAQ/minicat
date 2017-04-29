module WelcomeHelper
  def unread_count(contact)
    # 在自己的联系人页面，显示的都是自己作为 sender 的 Contact
    # 而 unread_count 的数据来源于自己作为 recipient 的 Contact
    recipient_contact = contact.recipient_contact
    !recipient_contact ?  0 : recipient_contact.unread_count
  end
end
