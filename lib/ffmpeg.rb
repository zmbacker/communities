require 'streamio-ffmpeg'
module CarrierWave
  module FFMPEG
    extend ActiveSupport::Concern

    module ClassMethods
      def convert_to_mp4 options
        process :convert_to_mp4 => options
      end

      def hb_convert_to_mp4 options
        process :hb_convert_to_mp4 => options
      end

      def hb_mobile_convert_to_mp4 options
        process :hb_mobile_convert_to_mp4 => options
      end

      def create_video_thumbnail options
        process :create_video_thumbnail => options
      end
    end

    def hb_convert_to_mp4
      tmp_path = uuid_name(current_path)
      mp4_tmp_path = tmp_path+".mp4"
      %x[HandBrakeCLI -Z Universal -i #{tmp_path} -o #{mp4_tmp_path}]
      File.delete( tmp_path )
      File.rename mp4_tmp_path, current_path
    end

    def hb_mobile_convert_to_mp4
      tmp_path = uuid_name(current_path, false)
      %x[HandBrakeCLI -Z Universal -i #{current_path} -o #{tmp_path} -e x264 -b 650 -T -2 -O -I -f mp4 -r 29.97 -a 1 -E faac -B 64 -6 dpl2 -R 48 -D 0.0 -f mp4 -X 480 -m -x cabac=0:ref=5:me=umh:bframes=0:subme=6:8x8dct=0:trellis=0:analyse=all]
      File.rename tmp_path, current_path
    end

    def convert_to_mp4 *args
      options = args.inject({}){|o, p| o[p.first] = p.last; o } # combining hash from array of pairs
      tmp_path = uuid_name(current_path)

      file = ::FFMPEG::Movie.new(tmp_path)
      tmp_mp4 = tmp_path+".mp4"
      tmp_st_mp4 = tmp_path+"st_.mp4"
      file.transcode(tmp_mp4 , options)
      p "running qt-faststart"
      command = %x[qt-faststart #{tmp_mp4} #{tmp_st_mp4}]
      File.rename tmp_st_mp4, current_path
      File.delete( tmp_path )
      File.delete( tmp_mp4 )
    end

    def create_video_thumbnail(h="00",m="00",s="02.0")
      # args = [h,m,s]
      # args.each_with_index do |t, index|
      #   if index != 0 and d = t.div(60)
      #     t = t-d*60
      #     args[index-1] = args[index-1]+d
      #   end
      #   t = "0"+t.to_s if t < 10
      # end
      # t = Time.at(file.duration/2)
      tmp  = current_path+".jpeg"
      path = File.absolute_path(current_path)
      file = ::FFMPEG::Movie.new(path)
      file.transcode(tmp, :custom => "-ss #{h}:#{m}:#{s} -s 435x264 -vframes 1 -f image2")
      File.rename tmp, current_path
      model.file_processing = nil
      if file and %w(presenter_merged_video regular).member? model.attachment_type
        Resque.enqueue(SendProcessedMessage, model.id)
      end
    end

    private
    def uuid_name current_path, rename_parent=true
      directory = File.dirname( current_path )
      tmp_file  = ["tmpfile", SecureRandom.uuid].join("-")+File.extname(current_path)
      tmp_path  = File.join( directory, tmp_file )
      File.rename current_path, tmp_path if rename_parent
      tmp_path
    end
  end
end
