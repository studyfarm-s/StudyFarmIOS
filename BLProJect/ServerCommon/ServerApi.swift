    //
    //  APIService.swift
    //  BLProJect
    //
    //  Created by 김도현 on 2020/09/07.
    //  Copyright © 2020 김도현. All rights reserved.
    //
    
    import UIKit
    import Alamofire
    import SwiftyJSON
    import SwiftKeychainWrapper
    
    
    
    //MARK - 메인스터디 리스트 데이터
    struct StudyDataModel {
        var study_seq : [Int] = []
        var users_seq : [Int] = []
        var title : [String] = []
        var email : [String] = []
        var name : [String] = []
        var phone : [String] = []
        var age : [Int] = []
        var nickname : [String] = []
        var state_code : [Int] = []
        var state_name : [String] = []
        var city_code : [Int] = []
        var city_name : [String] = []
        var gender : [String] = []
        var interesting_name : [String] = []
        var interesting_skill_level : [String] = []
        var contents : [String] = []
        var category_name : [String] = []
        var topic_name : [String] = []
    }
    
    //MARK - 스터디 디테일 데이터
    struct StudyOneDataModel {
        var study_seq : Int = 0
        var user_seq : Int = 0
        var title : String = ""
        var email : String = ""
        var name : String = ""
        var phone : String = ""
        var age : Int = 0
        var nickname : String = ""
        var state_code : Int = 0
        var state_name : String = ""
        var city_code : Int = 0
        var city_name : String = ""
        var gender : String = ""
        var interesting_name : String = ""
        var interesting_skill_level : String = ""
        var contents : String = ""
        var category_name : String = ""
        var topic_name : String = ""
    }
        
    //MARK - 댓글 등록 데이터
    struct CommentDataModel {
        var code : Int = 0
        var message : String = ""
    }
    
    //MARK - 대댓글 등록 데이터
    struct SubCommentDataModel {
        var code : Int = 0
        var message : String = ""
    }
    
    //MARK - 메인 스터디 등록 Paramter
    struct StudyRegisterParamter : Encodable {
        var title : String
        var study_limit : Int
        var week : String
        var week_type : Int
        var state : Int
        var city : Int
        var contents : String
        var category : String
        var topic : Int
        var color : String
        var study_day : Int
    }
        
    //MARK - 댓글 등록 Paramter
    struct CommentParamter : Encodable {
        var study_seq : Int
        var content : String
        var parent_reply_seq : Int
    }
    
    //MARK - 대댓글 등록 Paramter
    struct SubCommnetParamter : Encodable {
        var study_seq : Int
        var content : String
        var parent_reply_seq : Int
    }
    
    
    
    
    class ServerApi{
        static let shared = ServerApi()
        
        fileprivate let headers : HTTPHeaders = ["Content-Type": "application/hal+json;charset=UTF-8","Accept" : "application/hal+json"]
        public let Privateheaders : HTTPHeaders = ["Content-Type" : "application/hal+json;charset=UTF-8","Authorization" : "Bearer \(KeychainWrapper.standard.string(forKey: "token"))","Accept":"application/hal+json"]
        
        
        //MARK - DataModel Instace 초기화
        public var StudyModel = StudyDataModel()
        public var StudyOneModel = StudyOneDataModel()
        public var CommnetModel = CommentDataModel()
        public var SubCommentModel = SubCommentDataModel()
        
        private init() {}
        
        
        //MARK - Server Comment 댓글 등록 함수
        public func StudyCommentCall(CommentParamter : CommentParamter ,completionHandler : @escaping (Result<CommentDataModel,Error>) -> ()){
            AF.request("http://3.214.168.45:8080/api/v1/study-replies", method: .post, parameters: CommentParamter, encoder: JSONParameterEncoder.default, headers: Privateheaders)
                .response { response in
                    debugPrint(response)
                    switch response.result {
                    case .success(let value):
                        let CommentJson = JSON(value)
                        for (_,subJson):(String,JSON) in CommentJson["result"] {
                            print("스터디팜 댓글 번호 입니다",subJson["seq"].intValue)
                            print("스터디팜 작성자 입니다 ",subJson["writer"].arrayValue)
                            print("스터디팜 부모 댓글 번호 입니다",subJson["parent_reply_seq"].intValue)
                        }
                        completionHandler(.success(self.CommnetModel))
                    case .failure(let error):
                        print(error.localizedDescription)
                        completionHandler(.failure(error))
                    }
                    
                    
                    
                }
            
        }
        
        //MARK - Server Study 등록 요청 함수
        public func StudyRegisterCall(StudyRegisterParamter : StudyRegisterParamter, completionHandler : @escaping() -> ()){
            AF.request("http://3.214.168.45:8080/api/v1/study", method: .post, parameters: StudyRegisterParamter, encoder: JSONParameterEncoder.default, headers: Privateheaders)
                .response { response in
                    switch response.result {
                    case .success(let value):
                        let RegisterJson = JSON(value)
                        for (_,subJson):(String,JSON) in RegisterJson["result"] {
                            print("스터디팜 스터디 번호 \(RegisterJson["study_seq"].intValue)")
                            print("스터디팜 스터디 제목 \(RegisterJson["title"].stringValue)")
                            print("스터디팜 스터디 장 이메일 \(RegisterJson["email"].stringValue)")
                            print("스터디팜 스터디 닉네임 \(RegisterJson["nickname"].stringValue)")
                        }
                        completionHandler()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    
                }
        }
        
        //MARK - Server StudyList 조회 요청 함수
        public func StudyListCall(completionHandler :  @escaping () -> ()){
            AF.request("http://3.214.168.45:8080/api/v1/study", method: .get, parameters: nil, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .response { response in
                    debugPrint(response)
                    switch response.result {
                    case .success(let value):
                        let StudyJson = JSON(value)
                        for (_,subJson):(String,JSON) in StudyJson["result"]["study"] {
                            self.StudyModel.study_seq.append(subJson["study_seq"].intValue)
                            self.StudyModel.users_seq.append(subJson["users_seq"].intValue)
                            self.StudyModel.title.append(subJson["title"].stringValue)
                            self.StudyModel.name.append(subJson["name"].stringValue)
                            self.StudyModel.age.append(subJson["age"].intValue)
                            self.StudyModel.email.append(subJson["email"].stringValue)
                            self.StudyModel.phone.append(subJson["phone"].stringValue)
                            self.StudyModel.nickname.append(subJson["nickname"].stringValue)
                            self.StudyModel.state_code.append(subJson["user_city_info"]["state_code"].intValue)
                            self.StudyModel.state_name.append(subJson["user_city_info"]["state_name"].stringValue)
                            self.StudyModel.city_code.append(subJson["user_city_info"]["city_code"].intValue)
                            self.StudyModel.city_name.append(subJson["user_city_info"]["city_name"].stringValue)
                            self.StudyModel.interesting_name.append(subJson["interesting"]["name"].stringValue)
                            self.StudyModel.interesting_skill_level.append(subJson["interesting"]["skill_level"].stringValue)
                            self.StudyModel.contents.append(subJson["contents"].stringValue)
                            self.StudyModel.topic_name.append(subJson["topic_name"].stringValue)
                            self.StudyModel.category_name.append(subJson["category_name"].stringValue)
                            print("스터디팜 스터디 리스트 제목 입니다 : \(self.StudyModel.title)")
                            print("스터디팜 스터디 등록 이메일 입니다 : \(self.StudyModel.age)")
                            print("스터디팜 스터디 리스트 콘텐츠 입니다 : \(self.StudyModel.contents)")
                        }
                        completionHandler()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
        }
        
        //MARK - Server studyList 한건 조회 요청 함수
        public func StudyListOneCall(study_seq : Int, completionHandler : @escaping(Result<StudyOneDataModel,Error>) -> ()){
            AF.request("http://3.214.168.45:8080/api/v1/study\(study_seq)", method: .get,headers: Privateheaders)
                .response { response in
                    switch response.result {
                    case .success(let value):
                        let StudyOneJson = JSON(value)
                        for (_,subJson):(String,JSON) in StudyOneJson["result"] {
                            self.StudyOneModel.study_seq = StudyOneJson["study_seq"].intValue
                            self.StudyOneModel.user_seq = StudyOneJson["user_seq"].intValue
                            self.StudyOneModel.title = StudyOneJson["title"].stringValue
                            self.StudyOneModel.email = StudyOneJson["email"].stringValue
                            self.StudyOneModel.name = StudyOneJson["name"].stringValue
                            self.StudyOneModel.nickname = StudyOneJson["nickname"].stringValue
                            self.StudyOneModel.phone = StudyOneJson["phone"].stringValue
                            self.StudyOneModel.age = StudyOneJson["age"].intValue
                            self.StudyOneModel.gender = StudyOneJson["gender"].stringValue
                            self.StudyOneModel.interesting_name = StudyOneJson["interesting"]["name"].stringValue
                            self.StudyOneModel.interesting_skill_level = StudyOneJson["interesting"]["skill_level"].stringValue
                            self.StudyOneModel.contents = StudyOneJson["contents"].stringValue
                            self.StudyOneModel.category_name = StudyOneJson["category_name"].stringValue
                            self.StudyOneModel.topic_name = StudyOneJson["topic_name"].stringValue
                        }
                        completionHandler(.success(self.StudyOneModel))
                    case .failure(let error):
                        print(error.localizedDescription)
                        completionHandler(.failure(error))
                    }
                    
                }
        }
        
    }
    
    
    