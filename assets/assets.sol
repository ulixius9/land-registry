pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

contract asset {
    address public creatorAdmin;
	enum Status { NotExist, Pending, Approved, Rejected }
	
    
	struct PropertyDetail {
	    uint id;
		Status status;
		uint value;
		string add;
		address currOwner;
	}
	
	struct UserDetail {
		string name;
		uint aadhar;
	}
	
	uint public propertyCount = 0;
	mapping(uint => PropertyDetail) public properties;
	mapping(uint => address) public propOwnerChange;
	
    mapping(address => int) public users;
    mapping(address => UserDetail) public user_details;
    mapping(address => bool) public verifiedUsers;
    
    /* extra added */
    address[] usersAddList;

	modifier onlyOwner(uint _propId) {
		require(properties[_propId].currOwner == msg.sender);
		_;
	}

	modifier verifiedUser(address _user) {
	    require(verifiedUsers[_user]);
	    _;
	}

	modifier verifiedAdmin() {
		require(users[msg.sender] >= 2 && verifiedUsers[msg.sender]);
		_;
	}
    
	modifier verifiedSuperAdmin() {
	    require(users[msg.sender] == 3 && verifiedUsers[msg.sender]);
	    _;
	}
    
	constructor() public{
		creatorAdmin = msg.sender;
		users[creatorAdmin] = 3;
		verifiedUsers[creatorAdmin] = true;
	}
    
	function createProperty(uint _value,string memory _add, address _owner) public verifiedAdmin verifiedUser(_owner) returns (bool) {
		propertyCount++;
		properties[propertyCount] = PropertyDetail(propertyCount,Status.Pending, _value, _add, _owner);
		return true;
	}
    
	function approveProperty(uint _propId) public verifiedSuperAdmin returns (bool){
		require(properties[_propId].currOwner != msg.sender);
		properties[_propId].status = Status.Approved;
		return true;
	}
    
	function rejectProperty(uint _propId) public verifiedSuperAdmin returns (bool){
		require(properties[_propId].currOwner != msg.sender);
		properties[_propId].status = Status.Rejected;
		return true;
	}
    
	function changeOwnership(uint _propId, address _newOwner) public onlyOwner(_propId) verifiedUser(_newOwner) returns (bool) {
		require(properties[_propId].currOwner != _newOwner);
		require(propOwnerChange[_propId] == address(0));
		propOwnerChange[_propId] = _newOwner;
		return true;
	}

	function approveChangeOwnership(uint _propId) public verifiedSuperAdmin returns (bool) {
	    require(propOwnerChange[_propId] != address(0));
	    properties[_propId].currOwner = propOwnerChange[_propId];
	    propOwnerChange[_propId] = address(0);
	    return true;
	}
    
    function changeValue(uint _propId, uint _newValue) public onlyOwner(_propId) returns (bool) {
        require(propOwnerChange[_propId] == address(0));
        properties[_propId].value = _newValue;
        return true;
    }
    
	function getPropertyDetails(uint _propId) public view returns (Status, uint, address) {
		return (properties[_propId].status, properties[_propId].value, properties[_propId].currOwner);
	}
    
	function addNewUser(address _newUser,string memory _name,uint _aadhar) public verifiedAdmin returns (bool) {
	    require(users[_newUser] == 0);
	    require(verifiedUsers[_newUser] == false);
	    users[_newUser] = 1;
	    user_details[ _newUser ] =  UserDetail(_name,_aadhar);
	    //Extra Line
	    usersAddList.push(_newUser);
	    return true;
	}
    
	function addNewAdmin(address _newAdmin,string memory _name,uint _aadhar) public verifiedSuperAdmin returns (bool) {
	    require(users[_newAdmin] == 0);
	    require(verifiedUsers[_newAdmin] == false);
	    //Extra Line
	    user_details[ _newAdmin ] =  UserDetail(_name,_aadhar);
	    usersAddList.push(_newAdmin);
	    users[_newAdmin] = 2;
	    return true;
	}
    
	function addNewSuperAdmin(address _newSuperAdmin,string memory _name,uint _aadhar) public verifiedSuperAdmin returns (bool) {
	    require(users[_newSuperAdmin] == 0);
	    require(verifiedUsers[_newSuperAdmin] == false);
	    //Extra Line
	    user_details[ _newSuperAdmin ] =  UserDetail(_name,_aadhar);
	    usersAddList.push(_newSuperAdmin);
	    users[_newSuperAdmin] = 3;
	    return true;
	}
	
	function approveUsers(address _newUser) public verifiedSuperAdmin returns (bool) {
	    require(users[_newUser] != 0);
	    verifiedUsers[_newUser] = true;
	    return true;
	}
	
	/* for testing purpose */
	function getCurrentAccountAdd() public view returns(address){
	    return msg.sender;
	}
	
	function testConn() public pure returns(bool){
	    return true;
	}
	
	function getAddUserList() public view returns(address[] memory){
	    return usersAddList;
	}
	
	function checkAdmin() public view returns(bool){
	    require(users[msg.sender] >= 2 && verifiedUsers[msg.sender]);
	    return true;
	}
	
	function testAtr() public view returns(address[] memory,address[] memory){
	    return (usersAddList,usersAddList);
	}
	
	function getUserListToBeApproved() view public returns (address[100] memory,UserDetail[100] memory, uint){
	    uint count=0;
	    address [100] memory userAdds;
	    UserDetail [100] memory userData;
	    for(uint i=0;i<usersAddList.length;i++){
	        if(!verifiedUsers[usersAddList[i]]){
	            userAdds[count]=usersAddList[i];
	            userData[count]=user_details[usersAddList[i]];
	            count++;
	        }
	    }
	    return(userAdds,userData,count);
	}
	//neew
	function getPropertyListToBeApprovedNew() view public returns (PropertyDetail[100] memory,UserDetail[100] memory, uint){
	    uint count=0;
	    PropertyDetail [100] memory propData;
	    UserDetail [100] memory userData;
	    for(uint i=1;i<=propertyCount;i++){
	        if(properties[i].status==Status.Pending){
	            propData[count]=properties[i];
	            userData[count]=user_details[properties[i].currOwner];
	            count++;
	        }
	    }
	    return(propData,userData,count);
	}
	
	function getPropertyListToBeApproved() view public returns (PropertyDetail[100] memory,UserDetail[100] memory,uint){
	    uint count=0;
	    PropertyDetail[100] memory propertyData;
	    UserDetail [100] memory userData;
	    for(uint i=1;i<=propertyCount;i++){
	        if(properties[i].status==Status.Pending){
	            propertyData[count]=properties[i];
	            userData[count]=user_details[properties[i].currOwner];
	            count++;
	        }
	    }
	    return (propertyData,userData,count);
	}
	
	function getUserDetails(address _add) view public returns (UserDetail memory){
	    return user_details[_add];
	}
	
	function getMyProperties() view public returns (PropertyDetail[100] memory,uint,UserDetail memory){
	    uint count=0;
	    PropertyDetail[100] memory myPropertyData;
	    for(uint i=0;i<propertyCount;i++){
	        if(properties[i].currOwner==msg.sender){
	            myPropertyData[count]=properties[i];
	            count++;
	        }
	    }
	    UserDetail memory userdata=user_details[msg.sender];
	    return(myPropertyData,count,userdata);
	}
	
	function getPropertyListForOwnershipChange() view public returns (PropertyDetail[100] memory,UserDetail[100] memory,UserDetail[100] memory,uint){
	    uint count=0;
	    PropertyDetail[100] memory propertyData;
	    UserDetail [100] memory userDataOld;
	    UserDetail [100] memory userDataNew;
	    for(uint i=1;i<=propertyCount;i++){
	        if(propOwnerChange[i] != address(0)){
	            propertyData[count]=properties[i];
	            userDataOld[count]=user_details[properties[i].currOwner];
	            userDataNew[count]=user_details[propOwnerChange[i]];
	            count++;
	        }
	    }
	    return (propertyData,userDataOld,userDataNew,count);
	}
}