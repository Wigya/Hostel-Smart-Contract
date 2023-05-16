// SPDX-License-Identifier:s MIT

pragma solidity >=0.8.2 <0.9.0;
// Assumptions:
//          All rooms cost the same amount of eth;
//          There are 255 rooms;
contract Hostel {

    address public owner;
    mapping(uint8 => address) public RoomNumberToCustomer;
    mapping(uint8 => uint) public RoomExpireTime;
    uint private RoomPriceWei = 50000000000000000 wei; // 0.05 eth

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this function");
        _;
    }

    function RentRoom(uint8 _roomNumber, string memory _name, string memory _surname, uint _numberOfDays) payable public {
        bool isroomavailable = isRoomAvailable(_roomNumber);

        require(isroomavailable, "The room has already been taken");
        require(bytes(_name).length != 0, "Specify your name");
        require(bytes(_surname).length != 0, "Specify your surname");
        require(msg.value >= RoomPriceWei * _numberOfDays, "You haven't sent enough ether");

        RoomNumberToCustomer[_roomNumber] = msg.sender;
        RoomExpireTime[_roomNumber] = block.timestamp + _numberOfDays * 1 days;
    }

    function isRoomAvailable(uint8 _RoomNumber) public view returns(bool) {
        return (RoomNumberToCustomer[_RoomNumber] == address(0));
    }

    function getCurrentContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdrawAll(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
    }
 
    function changeRoomPrice(uint newPrice) public onlyOwner {
        RoomPriceWei = newPrice;
    }

    function getRoomsPrice() public view returns(uint) {
        return RoomPriceWei;
    }

    function checkRoomExpiration(uint8 _roomNumber) public view returns (uint) {
        return RoomExpireTime[_roomNumber];
    }

    function removeExpiredCustomersFromRooms() public {
        uint currentTime = block.timestamp;
        
        for(uint8 index = 1;index<=255;index++) {
            uint roomExpirationTime = RoomExpireTime[index];
            
            if((roomExpirationTime < currentTime) && (roomExpirationTime != 0)) {
                RoomExpireTime[index] = 0;
                RoomNumberToCustomer[index] = address(0);
            }
        }
    }
}