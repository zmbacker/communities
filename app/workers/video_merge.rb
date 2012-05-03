class VideoMerge
  @queue = :store_asset

  def self.perform(present_attachment, recorded_attachment_id, params)
    if not (present_attachment =~ /^[0-9]+$/).nil?
      _present_attachment = Attachment.find(present_attachment)
      p_att = File.join(Rails.root.to_s,"public", _present_attachment.file.webm.to_s)
    else
      p_att = present_attachment
    end
    recorded_attachment = Attachment.find(recorded_attachment_id)
    # r_att = File.join(Rails.root.to_s,"public", recorded_attachment.file.webm.to_s)
    r_att = recorded_attachment.file.path.to_s
    output = File.join(File.dirname(r_att), SecureRandom.uuid.split("-").join() + ".webm")

    # add_logo = false
    # logo = "movie=%{logo} [logo]; [in][logo] overlay=%{pos} [out]" % {
    #   :pos => self.add_position('tl'),
    #   :logo => misc_dir+'logo.png'
    # }

    options = {
      :output => output,
      :presentV => p_att,
      :recordedV => r_att,
      :pos => self.add_position(),
      :pad => self.add_pad(),
      :settings => '-map 0:0 -map 1:1 -async 1'
      # :metadata => '-title "OneWeekendInNYC"
      #               -author "Crazed Mule Productions, Inc."
      #               -copyright "2012"
      #               -comment "Video generated by orthodontics360"'
    }

    if p = params["position"] # :position
      if p == 'ml' or p == 'mr'
        options.merge!({:pad => self.add_pad(p)})
      end
      options.merge!({:pos => self.add_position(p)})
    end

    # command = 'ffmpeg -i %{presentV} -vf "movie=%{recordedV} [mv]; [in][mv] overlay=%{pos} [out]" -vcodec libx264 -preset medium %{output}' % options
    command = 'ffmpeg -i %{presentV} -i %{recordedV} -vf "movie=%{recordedV}, scale=180:-1, setpts=PTS-STARTPTS [movie];[in] setpts=PTS-STARTPTS, [movie] overlay=%{pos} [out]" %{settings} %{output}' % options
    command2 = 'ffmpeg -i %{presentV} -i %{recordedV} -vf "[in]setpts=PTS-STARTPTS, pad=%{pad},[T1]overlay=%{pos}[out];movie=%{recordedV},setpts=PTS-STARTPTS[T1]" %{settings} %{output}' % options

    cmd = %x[#{command}]

    recorded_attachment.item.attachments << Attachment.new({
      :file => File.open(output),
      :user => recorded_attachment.item.user,
      :attachment_type => "presenter_merged_video"})
    File.delete(output)
  end

  def self.add_pad(pad="mr", w=480, h=480, color="black")
    case pad
    when 'mr'
      'in_w+#{w}:in_h:0:0:#{color}'
    when 'ml'
      'in_w+#{w}:in_h:#{w}:0:#{color}'
    else
      'in_w+#{w}:in_h:0:0:#{color}'
    end
  end

  def self.add_position(pos="")
    case pos
    when 'tr'
      'main_w:0'
    when 'tl'
      '0:0'
    when 'br'
      'main_w-overlay_w:main_h-overlay_h'
    when 'bl'
      '0:main_h-overlay_h'
    when 'mr'
      'main_w-overlay_w:(main_h-overlay_h)/2'
    when 'ml'
      '0:(main_h-overlay_h)/2'
    when 'tm'
      '(main_w/2)-(overlay_w/2):5'
    when 'bm'
      '(main_w/2)-(overlay_w/2):main_h-overlay_h-5'
    else
      'main_w-overlay_w:main_h-overlay_h'
    end
  end
end