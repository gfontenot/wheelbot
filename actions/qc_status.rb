class QC_Status < CampfireBot::Action
  
  hear /qc status/i do
    check_qc_status
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
          speak "#{editor} has #{count} #{product} ready to pass to QC"
          found_files = true
        end

        qc_array.each_pair do |dir, person|
          count = Dir.entries("#{qc_dir}#{dir}#{person}").delete_if {|file| /^\./.match(file)}.size


          unless count == 0
            speak "#{person} has #{count} #{product} videos to QC"
            found_files = true
          end
        end
      rescue Exception => e
        puts e
      end
    end
    
    unless found_files
      speak "QC status is clean"
    end
    
  end
  
end