// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract UnknownNFT is ERC721Enumerable {
    event Compose(address indexed from, uint256 indexed fromTokenId, uint256 indexed toTokenId);

    uint256 private tid = 1;
    address  private mOwner;
    uint256 private mintPrice =  1 * 10**17;
    uint16 private mintNum = 0;
    uint16 private maxTotalSupply = 10000;
    uint private sd = 1;
    mapping(uint256=>Attribute)  private attributes;
    Pr[8]  private rPrs ;
    Pr[8]  private tPrs;

    constructor() ERC721("Unknown NFT", "UNKNOWN")  {
        mOwner = msg.sender;
        rPrs[0] = Pr(0,10,10,50,80,10,rs[0]);
        rPrs[1] = Pr(10,25,80,10,120,60,rs[1]);
        rPrs[2] = Pr(25,30,50,60,130,80,rs[2]);
        rPrs[3] = Pr(30,32,10,20,160,180,rs[3]);
        rPrs[4] = Pr(32,70,20,30,50,80,rs[4]);
        rPrs[5] = Pr(70,87,30,30,60,70,rs[5]);
        rPrs[6] = Pr(87,92,150,120,150,90,rs[6]);
        rPrs[7] = Pr(92,100,60,65,90,80,rs[7]);

        tPrs[0] = Pr(0,2,20,30,30,50,ts[0]);
        tPrs[1] = Pr(2,6,80,10,0,0,ts[1]);
        tPrs[2] = Pr(6,9,70,0,0,0,ts[2]);
        tPrs[3] = Pr(9,15,150,30,0,80,ts[3]);
        tPrs[4] = Pr(15,20,10,130,10,70,ts[4]);
        tPrs[5] = Pr(20,30,0,0,15,10,ts[5]);
        tPrs[6] = Pr(30,32,0,0,150,0,ts[6]);
        tPrs[7] = Pr(32,36,10,10,10,10,ts[7]);
    }

    function getAttribute(uint256 tokenId)  public view returns (uint16 , uint16, uint16, uint16, string memory,  string memory, string memory,string memory){
        Attribute memory attr = attributes[tokenId];
        return (attr.attack, attr.defense, attr.health, attr.dexterity, attr.race, attr.sex, attr.talent,attr.ancestry);
    }

    function getMintNum()  public view returns (uint16){
        return mintNum;
    }

   function tokenURI(uint256 tokenId) override public view returns (string memory) {
        Attribute memory attr = attributes[tokenId];
        require(attr.attack > 0);
        string memory output = string(abi.encodePacked(Utils.getTextStart(), Utils.getAttr('Name:  UNKNOWN # ',Utils.toString(tokenId) ),Utils.getTextEnd("40")
        ,Utils.getAttr('Race:  ', attr.race),Utils.getAttr('    Ancestry:  ', Utils.getColor(attr.ancestry)),   Utils.getTextEnd("60"),Utils.getAttr('Sex:  ', attr.sex),Utils.getTextEnd("80"),Utils.getAttr('Attack:  ', attr.attack)));
        output = string(abi.encodePacked(output,Utils.getTextEnd("100"),Utils.getAttr('Defense:  ', attr.defense),Utils.getTextEnd("120"),Utils.getAttr('Health:  ', attr.health)
        ,Utils.getTextEnd("140"),Utils.getAttr('Dexterity:  ', attr.dexterity),Utils.getTextEnd("160"),Utils.getAttr('Talent:  ', attr.talent),'</text></svg>'));       
    
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "UNKNOWN # ', Utils.toString(tokenId), '", "description": "Unknown Collection is additional randomized adventurer gear generated and stored on chain. Maximum supply is 10000,which can be synthesized.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function initAttr()internal  returns(Attribute memory){
        uint  _sd = sd ;
        uint8 rand = _random(_sd ++);
        //SEX
        Attribute memory attr ;
        attr.sex = rand <= 30 ? 'F':'M';
        rand = _random(sd ++);
        attr.attack = Utils.safeAdd(_random(_sd ++),30);
        attr.defense = Utils.safeAdd(_random(_sd ++),15);
        attr.health = Utils.safeAdd(_random(_sd ++),10);
        attr.dexterity = Utils.safeAdd(_random(_sd ++),25);
        
        uint8 r = _random(_sd ++);
        string memory a ;
        if(r < 2){ a = 'SSS';}
        else if(r < 6){ a= 'SS';}
        else if(r < 11){ a = 'S';}
        else if(r < 25){ a = 'A';}
        else if(r < 50){ a = 'B';}
        else if(r < 80){ a= 'C';}
        else{a = 'D';}
        attr.ancestry=a;
        //Race
        rand = _random(_sd ++);
        for(uint i = 0; i < rPrs.length; i++){
            if(rand >= rPrs[i].start  && rand < rPrs[i].end ){
                attr = addAttr(attr,rPrs[i]);
                attr.race = rPrs[i].val;
                break;
            }
        }
         //Talent
        rand = _random(_sd ++);
        for(uint i = 0; i < tPrs.length; i++){
            if(rand >= tPrs[i].start  && rand < tPrs[i].end ){
                attr = addAttr(attr,tPrs[i]);
                attr.talent = tPrs[i].val;
                break;
            }
        }
        sd = _sd;
        return attr;
    }

    function  addAttr(Attribute memory attr ,Pr memory pr) internal pure returns(Attribute memory rattr ){
        attr.attack = Utils.safeAdd(attr.attack ,pr.attack );
        attr.defense = Utils.safeAdd(attr.defense,pr.defense);
        attr.health = Utils.safeAdd(attr.health,pr.health);
        attr.dexterity = Utils.safeAdd(attr.dexterity ,pr.dexterity);
        return attr;
    }
   
    function compose(uint256 tokenIdFrom,uint256 tokenIdTo)public {
        require(ERC721.ownerOf(tokenIdFrom) == msg.sender, "Ownable: tokenIdFrom is not the owner");
        require(ERC721.ownerOf(tokenIdTo) == msg.sender, "Ownable: tokenIdTo is not the owner");
        sd ++;
        uint8 rand = _random(sd);
        rand += 30;
        if(rand > 100){
            rand = 100;
        }
        Attribute memory attrTo = attributes[tokenIdTo];
        Attribute memory attrFromm = attributes[tokenIdFrom];
        attrTo.attack = Utils.safeAdd(attrTo.attack ,attrFromm.attack*rand/100);
        attrTo.defense = Utils.safeAdd(attrTo.defense,attrFromm.defense*rand/100);
        attrTo.health = Utils.safeAdd(attrTo.health,attrFromm.health*rand/100);
        attrTo.dexterity = Utils.safeAdd(attrTo.dexterity ,attrFromm.dexterity*rand/100);
        attrTo.talent = attrFromm.talent;
        attributes[tokenIdTo] = attrTo;
        emit Compose(msg.sender,tokenIdFrom,tokenIdTo);
        _burn(tokenIdFrom);
    }


    function mint(uint num)payable public {
        require(num <= 10,'Max Mint 10 at one time');
        uint256 price = mintPrice * num;
        require(price==msg.value,"Price mismatch");
        require(mintNum+num <= maxTotalSupply,'Maximum totalSupply');
       
        address payable rec = payable(mOwner);
        rec.transfer(msg.value);
        for(uint i=0; i < num;i++){
            uint256 tokenId = tid;
            super._safeMint(msg.sender,tokenId);
            attributes[tokenId] = initAttr();
            tid ++;
            mintNum ++;    
        }
       
    }


    function _burn(uint256 tokenId) internal override {
        super._burn(tokenId);
        delete attributes[tokenId];
    }

    function _random(uint _sd) internal view  returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp,msg.sender,_sd,block.difficulty)))%100);
    }

    string[] rs = [ "Orcs", "Demons", "Protoss", "Elves", "Humans", "Dwarves", "Dragons", "Goblins"]; //race
    string[] ts = ["Creation", "Forging", "Construction", "Fight", "Guard", "Production", "Medicine", "Knowledge"]; //talent
    struct Pr{
        uint8 start;
        uint8 end;
        uint16 attack;
        uint16 defense;
        uint16 health;
        uint16 dexterity;
        string val;
    }
   
     struct Attribute{
        uint16 attack;
        uint16 defense;
        uint16 health;
        uint16 dexterity;
        string race;
        string sex;
        string talent;
        string ancestry;
    }
}

library Utils{
    function getAttr(string memory name,string memory val)internal pure returns(string memory){
        return string(abi.encodePacked(name, val));
    }
    function getAttr(string memory name,uint16 val)internal pure returns(string memory){
        return getAttr(name,Strings.toString(val));
    }
    function getTextEnd(string memory y)internal pure returns(string memory){
        return string(abi.encodePacked('</text><text x="10" y="',y,'" class="base" xml:space="preserve">'));
    }
     function getTextStart()internal pure returns(string memory){
        return '<svg xmlns="http://www.w3.org/2000/svg"  viewBox="0 0 280 280"><style>.base { fill: white; font-family: serif; font-size: 16px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base" xml:space="preserve">';
    }
   
    function safeAdd(uint16  first,uint16 second) internal pure returns (uint16) {
        uint16 result = first+second;
        return result > 1000?1000:result;
    }
    function getColor(string memory val)internal pure returns(string memory){
        string memory c ;
        if(compareStr(val,"SSS")){ c='#8d4bbb';}
        else if (compareStr(val,"SS")){ c='#eacd76';}
        else if (compareStr(val,"S")){ c='#ff4c00';}
        else{ c='white';}
        return string(abi.encodePacked('<tspan style="fill:',c,'">',val,'</tspan>'));
    }
    function compareStr (string memory a,string memory b) internal pure returns(bool) {
        bool checkResult;
        if(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b))) {
            checkResult = true;
        }
        return checkResult;
    }
    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 val) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (val == 0) {
            return "0";
        }
        uint256 temp = val;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (val != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(val % 10)));
            val /= 10;
        }
        return string(buffer);
    }
}


/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
            mstore(result, encodedLen)
        }
        return string(result);
    }
}