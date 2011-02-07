class QC_Status
  
  def initialize room
    @room = room
  end
  
  
  def hear
    /qc status/i
  end
  
  def perform
    check_qc_status
  end
  
  def desc_short
    "qc status"
  end
  
  def desc_long
    "Check the QC folders for files that need to be acted upon, and report back."
  end
  
  def check_qc_status
    base_dir = @config["qc"]["base_dir"]
    product_array = @config["qc"]["product_editor"]
    qc_array = @config["qc"]["qc_steps"]
    
    found_files = false
    
    product_array.each_pair do |product, editor|

      qc_dir = File.join(base_dir, product, "/Latest Batch/QC/")
      begin
        count = Dir.entries("#{qc_dir}0_Editor Review_#{editor}").delete_if {|file| /^\./.match(file)}.size
        unless count == 0
          @room.speak "#{editor} has #{count} #{product} ready to pass to QC"
          found_files = true
        end

        qc_array.each_pair do |dir, person|
          count = Dir.entries("#{qc_dir}#{dir}#{person}").delete_if {|file| /^\./.match(file)}.size


          unless count == 0
            @room.speak "#{person} has #{count} #{product} videos to QC"
            found_files = true
          end
        end
      rescue Exception => e
        puts e
      end
    end
    
    unless found_files
      @room.speak "QC status is clean"
    end
    
  end
  
end