require 'net/http'

class FileController < ApplicationController

  def upload
    file = params[:file]
    File.open('../video/video_storage/p_source/' + file.original_filename, "wb") do |f|
      f.write(params[:file].read)
    end
    redirect_to "/file/load/#{file.original_filename}"
  end

  def load
    @file_name = params[:name]
  end

  def convert
    Resque.enqueue(VideoConvert, params[:name])
  end

  def merge
    Resque.enqueue( VideoMerge,
                    params[:presentationVideoFileName],
                    params[:recordingFileName],
                    {}
                  )
    render :json => {success: true, msg: "merge request added to Q"}
  end

  # def thumbnail
  #   ffmpeg  -itsoffset -4  -i test.avi -vcodec mjpeg -vframes 1 -an -f rawvideo -s 320x240 test.jpg
  # end

end
