// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

contract NFTwitter is ERC721 {

    struct Tweet {
        uint256 tweetId;
        uint256 parentId;
        string content;
        uint256 timestamp;
        address author;
        address owner;
    }

    uint256 private _tweetIds;
    mapping(uint256 => Tweet) private tweets;
    mapping(address => uint256[]) private tweetsByOwner;
    mapping(uint256 => uint256[]) private tweetsReplies;

    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    event newTweet(uint256 tweetId);
    event tweetDeleted(uint256 tweetId);

    constructor() ERC721("NFTwitter", "NFTT") {
        _tweetIds = 1;
    }

    function tweet(string memory content, uint256 parentId) external {
        require(bytes(content).length > 0, "Tweet must have a content !");
        require(_exists(parentId) || parentId == 0, "Parent tweet does not exist");         //no parent -> id = 0 (tweets ids starts at 1)
        uint256 newTweetId = _tweetIds;
        _safeMint(msg.sender, newTweetId);

        tweets[newTweetId] = Tweet({
            tweetId: newTweetId, parentId: parentId, content: content, timestamp: block.timestamp, author: msg.sender, owner: msg.sender
        });

        tweetsByOwner[msg.sender].push(_tweetIds);
        if(parentId != 0)
        {
            tweetsReplies[parentId].push(newTweetId);
        }
        
        _tweetIds++;

        emit newTweet(newTweetId);
    }

    function deleteTweet(uint256 _tokenId) external {
        _burn(_tokenId);

        emit tweetDeleted(_tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._transfer(from, to, tokenId);

        tweets[tokenId].owner = to;
        tweetsByOwner[to].push(tokenId);
        delete tweetsByOwner[from][tokenId];
    }

    modifier requireTweetExists(uint256 _tokenId)
    {
        require(_exists(_tokenId), "Tweet does not exists");
        _;
    }

    function tokenURI(uint256 _tokenId) public view override requireTweetExists(_tokenId) returns (string memory) {
        string memory json = Base64.encode(
            bytes(
            string(
                abi.encodePacked(
                '{"name": "NFTweet #',
                Strings.toString(_tokenId),
                '", "description": "This NFT is a tweet.", "image": "',
                tweetImageURI(_tokenId),
                '", "attributes": [ { "trait_type": "Parent Tweet Id", "value": "', Strings.toString(tweets[_tokenId].parentId),'"}, { "trait_type": "Content", "value": "',
                tweets[_tokenId].content,'"} ]}'
                )
            )
            )
        );

        string memory output = string(
            abi.encodePacked('data:application/json;base64,', json)
        );
        
        return output;
    }

    function tweetImageURI(uint256 _tokenId) public view requireTweetExists(_tokenId) returns (string memory) {
        string memory svg = string(abi.encodePacked(baseSvg, tweets[_tokenId].content, '</text></svg>'));
        
        return string(abi.encodePacked('data:image/svg+xml;base64,', Base64.encode(bytes(svg))));
    }

    function getTweetsOfOwner(address owner) public view returns (Tweet[] memory) {
        uint256[] memory ownerTweets = tweetsByOwner[owner];
        uint totalCount = ownerTweets.length;

        uint count = 0;
        for(uint i = 1; i < totalCount; i++)
        {
            if(_exists(ownerTweets[i]))
                count++;
        }

        Tweet[] memory tweetsList = new Tweet[](count);
        uint indice = 0;
        for(uint i = 0; i < count; i++)
        {
            if(_exists(ownerTweets[i]))
            {
                tweetsList[indice] = tweets[ownerTweets[i]];
                indice++;
            }
        }

        return tweetsList;
    }

    function getTweet(uint256 _tokenId) public view requireTweetExists(_tokenId) returns (Tweet memory) {
        return tweets[_tokenId];
    }

    function getReplies(uint256 _tokenId) public view requireTweetExists(_tokenId) returns (Tweet[] memory) {
        uint256[] memory replies = tweetsReplies[_tokenId];
        uint totalCount = replies.length;

        uint count = 0;
        for(uint i = 1; i < totalCount; i++)
        {
            if(_exists(replies[i]))
                count++;
        }

        Tweet[] memory tweetsList = new Tweet[](count);
        uint indice = 0;
        for(uint i = 0; i < count; i++)
        {
            if(_exists(replies[i]))
            {
                tweetsList[indice] = tweets[replies[i]];
                indice++;
            }
        }

        return tweetsList;
    }

    function getTweets() public view returns (Tweet[] memory) 
    {
        uint count = 0;
        for(uint i = 1; i < _tweetIds; i++)
        {
            if(_exists(i))
                count++;
        }
        Tweet[] memory tweetsList = new Tweet[](count);

        uint indice = 0;
        for(uint i = 1; i < _tweetIds; i++)
        {
            if(_exists(i))
            {
                tweetsList[indice] = tweets[i];
                indice++;
            }
        }
        return tweetsList;
    }
}