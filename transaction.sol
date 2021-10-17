pragma solidity ^0.6.0;

contract transaction{

    enum V_Statues{ varified,not_varified }
    V_Statues V_currentStatus;
    enum M_Statues{ matured,unmatured }
    M_Statues M_CurrentStatus;
    enum C_Status{ claimed,unclaimed }
    C_Status C_CurrentStatus;

    uint private count=0;
    uint  creationtTime;
    uint month=0;

    event occupy(address _occupant, uint _value);
    //owner is Bank
    address payable public Authurity;
    address payable public Policy_holder;

    uint selected=0;
    string public checkPolicy= "Please select a suitable policy \n 1.3month. \n 2. 4month. \n 3. 5month.";
    string memry;

    constructor() public{
        Authurity=msg.sender;
        M_CurrentStatus = M_Statues.unmatured;
        V_currentStatus = V_Statues.not_varified;
        C_CurrentStatus = C_Status.unclaimed;
    }

    modifier needed{
        require(M_CurrentStatus == M_Statues.unmatured,"Your policy is already matured.");
        _;
    }
    modifier costs(uint _amount){
        require(msg.value == _amount," payment not enough." );
        _;
    }
    modifier maturity{
        require(M_CurrentStatus == M_Statues.matured,"Not matured yet.");
        _;
    }
    modifier varification{
        require(V_currentStatus == V_Statues.varified,"Please varify first.");
        _;
    }
    modifier _authurityOnly{
        require(msg.sender == Authurity,"Only authurity can access this");
        _;
    }
    modifier unvalid{
        require(selected <4  && selected >0 ,"No policy selected");
        _;
    }
    modifier onlyAfter(uint _time) {
        require(now >= _time,"too early.");
        _;
    }
    modifier _new{
        require(selected == 0 ,"Only one valid policy is available at a time");
        _;
    }
    modifier _holderOnly{
        require(msg.sender == Policy_holder,"Policy holder only");
        _;
    }
    modifier same{
        require(msg.sender != Authurity,"Invalid account");
        _;
    }
    modifier claims{
        require(C_CurrentStatus == C_Status.claimed,"Not claimed yet");
        _;
    }

     function Selected_policy() public view unvalid returns(uint){
        return selected;

    }
      function Select_policy(uint  _select) public same _new returns(string memory invld){
        if(_select <=3 && _select >0){
            selected = _select;
            Time_setting();
        }
        else{
            memry = "Invalid";
                    }
        Policy_holder=msg.sender;
        creationtTime=now;
        return memry;
    }

    function Time_setting() private {
        if(selected==1)
        {
            month=3;
        }
        else if(selected ==2)
        {
            month=4;
        }
        else if(selected==3)
        {
            month=5;
        }
    }
    function claim() public _holderOnly maturity(){
        C_CurrentStatus=C_Status.claimed;
    }

    function getCount() private view returns (uint) {
        return count;
    }

     function MakePayment() external payable unvalid needed costs(2 ether) {


        Authurity.transfer(msg.value);

        emit occupy(msg.sender,msg.value);

        count = count+1;
        setCount();
    }

    function setCount() private{
        if(count>=month){
            M_CurrentStatus=M_Statues.matured;
        }
    }

    function verify() public _authurityOnly maturity claims{
        V_currentStatus=V_Statues.varified;
    }

    function Send() external payable _authurityOnly maturity claims varification{

        Policy_holder.transfer(15 ether);
        emit occupy(msg.sender,msg.value);
        selected =0;
        count=0;
        V_currentStatus=V_Statues.not_varified;
        M_CurrentStatus=M_Statues.unmatured;
        C_CurrentStatus=C_Status.unclaimed;
    }

    function checkBalance() public view returns(uint accountBalance){
        accountBalance = (msg.sender).balance/(1 ether);
    }

    function InstalmentAndPayment() public view _holderOnly needed returns(uint instalment,uint payment_done){
        instalment=count;
        payment_done=count*2;
    }
}
