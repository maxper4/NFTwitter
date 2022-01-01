// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract NFTwitter is ERC721 {

    struct Tweet {
        uint256 parentId;
        string content;
    }

    uint256 private _tweetIds;
    mapping(uint256 => Tweet) public tweets;
    mapping(address => uint256[]) public tweetsByAuthor;
    mapping(uint256 => uint256[]) public tweetsReplies;

    event newTweet(address sender, uint256 tweetId);
    event tweetDeleted(uint256 tweetId);

    constructor() ERC721("NFTwitter", "NFTT") {
        _tweetIds = 1;
    }

    function tweet(string memory content, uint256 parentId) external {
        uint256 newTweetId = _tweetIds;
        require(_exists(parentId) || parentId == 0, "Parent tweet does not exist");         //no parent -> id = 0 (tweets ids starts at 1)
        _safeMint(msg.sender, newTweetId);

        tweets[newTweetId] = Tweet({
            parentId: parentId, content: content
        });

        tweetsByAuthor[msg.sender].push(newTweetId);
        if(parentId != 0)
        {
            tweetsReplies[parentId].push(newTweetId);
        }
        
        _tweetIds++;

        console.log("New tweet with parent tweet %s : %s", parentId, content);

        emit newTweet(msg.sender, newTweetId);
    }

    function deleteTweet(uint256 id) external {
        _burn(id);

        emit tweetDeleted(id);
    }

    function getTweetsIds(address author) public view returns (uint256[] memory) {
        return tweetsByAuthor[author];
    }

    function getTweet(uint256 id) public view returns (Tweet memory) {
        return tweets[id];
    }

    function getRepliesIds(uint256 id) public view returns (uint256[] memory) {
        return tweetsReplies[id];
    }
}