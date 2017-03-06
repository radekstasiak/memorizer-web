require 'httparty'
require 'json'

class ApiTranslationController < BaseApiController

	api :POST, "/translate/full/", "Use this API to get translation"
    error :code => 401, :desc => "Unauthorized. Details don't match with any device in the database"
    param :word, String, 'translated word',:required => true
    param :sl, String, 'original language', :required => true
    param :tl, String, 'translation language', :required => true
	def full_translation

		@word = params[:word]
		@sourceLang = params[:sl]
		@translateLang = params[:tl]
		@params = '?client=gtx&sl='+@sourceLang+'&tl='+@translateLang+'&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t'+'&q='+@word
		response = HTTParty.post('https://translate.googleapis.com/translate_a/single'+@params)

		case response.code
		when 200
			@jsonArray=response.body
    			while @jsonArray.include?(',,') or @jsonArray.include?('[,') or @jsonArray.include?(',]')
						puts(@jsonArray)
						@jsonArray.gsub!(',,',',"",')
						@jsonArray.gsub!(',]',',""]')
						@jsonArray.gsub!('[,','["",')
					end
			@result = JSON.parse(@jsonArray)
		else
			@result=response.code
		end
		
		
		#render :json => {:type => @result}
		render :json => {:statusCode =>response.code.to_s,
						 :data =>{
						 	:translatedText => @result[0][0][0],
						 	:originalText => @result[0][0][1],
						 	:sourceLang => @result[2],
						 	:alternateTranslations => {
						 		@result[1][0][0]=>@result[1][0][1]
						 		} 
							}
						}

	end

end

