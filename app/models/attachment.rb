class Attachment < ActiveRecord::Base
  belongs_to :item #, :counter_cache => true
  belongs_to :user #, :counter_cache => true

  attr_accessible :user, :file

  # validates_presence_of :user

  #File upload
  mount_uploader        :file, FileUploader
  process_in_background :file
  store_in_background   :file

  def extension_is?(ext)
    dot_ext = [".", ext].join()
    File.extname(file.path) == dot_ext
  end

  def is_pdf?
    extension_is?("pdf")
  end

  def is_video?
    extension_is?("mp4")
  end

  def is_processed_to_pdf?
    not file.pdf.nil?
  end

end