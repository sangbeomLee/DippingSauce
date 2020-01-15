/*
 1. storyboard로 오토레이아웃 잡아놓고 내용물 채우기.
 2. viewController에 다 넣으면 많아지니 ViewController+UI에 필요한 부분을 extension하여 추가하였다.
 2020-01-03
 3. Firebase를 cocoaPod을 이용하여 프레임워크를 등록하였다.
 4. 각종 연결을 하였으며 Authentication 에 사용자 이메일 사용한다고 한 뒤 이메일 등록부터 진행하였다.
 5. FirebaseAuth를 사용하여 이메일 등록에 성공
 6. FirebaseDatabase중 realTimebase를 사용하여 내가 원하는 모델? < 나중에 추가할 것 (이름, 이메일, 비밀번호)등의 정보를 전달 해 주었다.
 7. FirebaseStorage를 이용하여 avarta에 사용할 이미지를 저장 하였고 database에는 그 Storage에 저장된 url을 저장 해 주었다.
 8. PrgressHUD open source를 이용하여 알림창을 띄워 주었다.
 9. 결과적으로 signUP이 잘 작동하나 확인.
 10. 모든 것을 SignUpviewController+UI에 넣었기 때문에 코드가 겹치는 부분이 많았기에 코드 정리를 시작하였다.
 11. 우선 Struct로 Api파일을 만들었고 크게 User, Message를 static으로 가진다.(Message)는 추후 사용할 것
 12. UserApi를 만들고 내부에 함수들을 정의 하였다. ex) signUp, signIn, forgotPassword etc..
 13. 재사용성이 높은 StorageService를 따로 빼네어 database에 관한 storage를 정리해 주었다. savePhoto가 있다.
 14. Ref 에는 내가 사용할 각종 상수를 정의하고(alert message) 각종 루트 rootStorage, rootDatabase etc.. 등을 정의해 주었다.
 15. 무조건 입력해야하는 email, name, password, image등을 확인해 주는 함수도 만들었으며, 눈에 확 들어오게 작은 함수들로만 겉으로 나온다.
 16. 이렇게 코드를 나누어 재사용성을 높인 뒤 SigninViewController를 진행 하였다.
 17. 직접 사용할 함수를 정의하고 signIn함수를 UserApi에 정의 하였다.
 18. forgotPassword도 마찬가지이다.
 19. firebase에서 기본적으로 제공해주는 함수가 많다.(비밀번호 찾기, 등등) 이것들을 활용하여 이번앱을 잘 만들어봐야겠다.
 -------
 ios 13부터는 AppDelegate 와 SceneDelegate가 분리되어있다. 주의하자.(appDelegate에 window가 없다.)
 2020-01-04
 20. login을 하여 메인 컨텐츠 활용을 위해 tapbarController를 만들었으며 총 3개의 아이템을 가진다.
 21. storyboard는 따로 구성하였는데 하나의 storyboard로만 하는 강의에서와 달라 약간 애를 먹었다.(string point)
 22. Message, Users 둘 다 테이블 뷰 컨트롤러를 사용했다. (UIViewController에서 추가했어도 무리없을듯 하다.)
 23. Users위주로 구현 하였으며 Tableview에 Cell을 CustomCell(UserTableViewCell)로 만들었다.
 24. Cell에 User정보를 입력 해야 하는데 이때 Database에서 정보를 가져오는 옵저버가 필요해 구현하였다.
 25. 옵저버를 구현하는 도중에 User의 모델이 필요하여 User를 만들었다.
 26. User정보를 가져오는데 있어서는 UserApi가 해야 하는 일이기때문에 UserApi에 함수를 구현하였다.
 27. 이부분에서 onSuccess 클로저가 많은일을 담당하였고 실 사용은 TableView에서 해야했기에 이부분을 클로저로 구현하였다.
 28. 또한 typealias 를 이용하여 조금 더 가독성좋은 코드를 구현하였다.
 29. 가져온 정보를 Cell에 넣어줌에 있어서 UIImage를 Url로 구현해야하는 이슈가 발생하였다.
 30. SDWebImage라는 opensource를 사용하여 구현하였다.
 31. 구현에는 Extension 파일을 만들고 UIImage를 extension하여 구현하였다.
 32. 위의 작업들을 통해서 import해야 하는 부분이 실제로 controller부분에는 상당히 적어지는게 눈에 보였다.
 33. user정보를 모두 받아온 후, navigationBar에 searchController를 부착하여 검색을 할 수 있게 하였다.
 34. 이 부분에서 하나만 있을 때 (if, else) 보다 bool ? a : b 의 가독성을 느낄 수 있었다.
 35. 각각의 설정을 다 한뒤 resultUser에 result값들을 넣어주었으며 이 과정에서 string클래스의 비교구문을 살펴볼 수 있었다.
 36. 특히 filter라는 좋은 함수를 사용하였다. 함수를 정말 많이 알아야 많이 써먹을 수 있을 것이라 느껴진다.
 37. logOut 부분도 진행하였는데 이부분은 user의 정보를 끝내는 것이기에 UserApi에 구현하였다.
 38. Api로 구분지어놓으니 너무 사용성도 높고 가독성이좋아 꼭 이렇게 구현을 해야겠다.
 --------
 2020-01-05
 39. ChatViewController를 만들고 Storyboard를 tableView와 view(keyboard)쪽으로 구성해주었따.
 40. ChatViewController에 navigationbar들을 정리해 주었다.
 41. chatViewController에는 tapBar가 나오면 안되고 이런 자잘한 것들을 정리해주었다.
 42. Keyboard가 들어가는 자리를 설정해주었다.
 43. inputTextView정리 하였다.
 44. databaseStorage에 video, image를 넣었다.
 45. videoUrl, imageUrl을 database에 넣어주어 관리하였다.
 46. Id값을 파일이름으로 사용하면 Storage에 같은 이름으로 저장되기 때문에 NSUUID를 사용해서 유니크한 이름을 지정해 주었다.
 47. 사용자가 메시지를 서로 주고받아야한다.
 --------
 2020-01-06
 49. MessageTableViewCell을 구성하였다.
 2020-01-07
 50. sendMessage에 inbox를 만드는 것을 추가하였다.
 51. inbox에 imageUrl or like this 를 뺏다.
 52. inbox model을 만들어주었다. (text, user, read, date)가 있다.
 53. inbox 설정을 PeopleTableView와 비슷하게 해주었다.
 54. 여러개의 셀을 테이블 뷰에 넣고싶으면 테이블 뷰에 style -> static으로 바꾼다.
 55. cell 의 Accessry 부분이 > 이렇게 넘어가는 부분같은데 정확히 알자
 56. profile부분을 마무리 하였다. 이부분에서 중요히 여길점은 기존에 사용한 api들을 적절히 사용하고 또 알맞게 고쳐가면서 필요한 부분만 만들어 사용하는것이 중요하다.
 57. 약간 어렵긴 하다 하지만 이해 못할 수준은 아니다.
 -----------
 2020-01-09
 58. Notification Messages
 59. notification 을 사용하려면 애플 서버에 연결 해주어야 하며 firebase에도 설정 해야한다.
 60. 또한 appdelegate에서 여러 설정을 한 뒤 사용 할 수 있다.
 61. 하지만 시뮬레이터로는 돌아가지 않는듯 하다(token이 안나옴.)
 62. notifications are not supported in the simulator 라는 에러가 나옴. notification은 기기를 가져와서 해보도록 하자.
 63. user online << 들어와 있는지 안들어와있는지 확인하는 것
 64. isActive 부분이 잘 안된다. 다시 봐서 고쳐야한다.
 ------------------
 2020-01-10
 65. observeSingEvent로 처음 어떤지 보고 상태를 결정 한 뒤 observe(changeChild) 로 바뀔때마다 바뀐 값을 가져와 active 로 보여준다.
 66. 타이핑 하고 있을 때 타이핑 하는지를 전달받아 알려주는 것을 구현할 것이다.
 67. var typing: Bool, var timer: Timer()를 만들어 주었다.
 68. 상대방의 dict[typing] 에 나의 id가 들어잇으면 typing...이라는 글자가 나오게 되고 3초간 상대방이 typing이 없으면 다시 activ 상태로 돌아가게 된다.
 2020-01-11
 68. Message부분에서 메시지가 와도 바로바로 갱신안된다. 이부분 해결
 69. profileImage를 바꿨을 때 Message부분의 profile도 바뀌게 수정.
 70. keyboard Inputview가 같이 위로 올라오고 같이 내려오도록 설정하였다.
 71. message를 feedMessage로 바꾸는 작업을 하는 듯 하다.
 72. pagination을 하려면 이렇게 좀 바꿔야하는듯 하다.
 73. refreshControl 을 만들어 줬다 사용용도는 리프레쉬 할때 위에서 아래로 당기면 리프래쉬가 되게 하는것이다.
 74. fireBase에 저장할 때 위에서 아래로 계속 저장하는것을 이용해서 refresh를 구현한다.
 75. loadMore() 함수들을 구현하였다. 어렵구나
 76. headerTimeLabel만들었다.
 2020-01-12
 77. navigationBarLeftItem 에 location을 넣어주고 화면 이동을 시켰다.
 78. AroundStroyboard를 구성하였다.(collectionView사용)
 79. collectionView사이즈 조절이 안될 때 storyboard에서 estimate size를 none으로 해야한다.
 80. profile에서 gender와 age부분 추가.
 81. CoreLocation을 사용 location관련해서 사용하려면 info에서 location관한 퍼미션을 받아야한다.
 2020-01-13
 82. GeoFire오픈소스 사용
 83. UserAroundViewController에서 location에 관한 설정을 하였다.
 84. UserAroundViewController에서 nearbyFirends들을 찾는 작업을 하였다.
 85. userdata를 가져오는 부분의 로직은 UserTableViewCell의 observe와 같기 때문에 그 부분을 활용 하였다.
 86. 사용자의 성별에 따라 나오게 하였으며 findUser()를 만들었다.
 87. 사용자의 거리를 계산하기 위해 database에 userinfo 에 latitude, longitude를 넣어주었다.(위도, 경도)
 88. mapView를 만든다.
 89. mapViewController에 map을 사용하기 위해 MapKit을 사용한다.
 90. 위치를 시뮬레이터라서 이상한곳을 잡는것인지 아니면 내가 위도경도를 잘못 찾아서 그런것인지 확인해야한다.(시뮬이라서 그렇다)
 91. 후에 dummyUser들의 위도와 경도를 설정값을 줘서 테스트 해보자
 2020-01-14
 92. 핸드폰 테스트 결과 괜찮게 나옴 호달달
 93. 내부 annotation설정 하였다.
 94. 사용자간의 길을 알려주는 것을 표기한다.
 95. detailView를 구성한다.
 96. facebook login을 하였다..
 
 
 
 
 
 
 
 
 */
