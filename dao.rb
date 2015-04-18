
class Dao
    @@FILE_NAME = "./train_data.dat"
    
    def write_to_file(histories)
       	data_to_be_recoded = ""
        histories.each do |context,sub|
            data_to_be_recoded << "["
            data_to_be_recoded << context
            data_to_be_recoded << "]#"
            sub.each do |k,v|
                data_to_be_recoded << k
                data_to_be_recoded << "*"
                data_to_be_recoded << v.get_all_regret_sum.to_s
                data_to_be_recoded << "#"
            end
        end

        compressed_data = Zlib::Deflate.deflate(data_to_be_recoded)
        File.binwrite(@@FILE_NAME,compressed_data)
        puts "trained" 
        
    end
    
    def read_from_file()
        compressed = File.binread(@@FILE_NAME)
        return compressed
    end
    
end