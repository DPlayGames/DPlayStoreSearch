pragma solidity ^0.5.9;

import "./DPlayStoreSearchInterface.sol";
import "./DPlayStoreInterface.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DPlayStoreSearch is DPlayStoreSearchInterface, NetworkChecker {
	using SafeMath for uint;
	
	mapping(uint => mapping(string => GameTags)) private gameIdToLanguageToTags;
	
	DPlayStoreInterface private dplayStore;
	
	constructor() NetworkChecker() public {
		
		// DPlay Store 스마트 계약을 불러옵니다.
		// Loads the smart contract of DPlay Store.
		if (network == Network.Mainnet) {
			//TODO
		} else if (network == Network.Kovan) {
			dplayStore = DPlayStoreInterface(0xfBA183939161ae03996b094F9DD67473b7e8F855);
		} else if (network == Network.Ropsten) {
			//TODO
		} else if (network == Network.Rinkeby) {
			//TODO
		} else {
			revert();
		}
	}
	
	// 언어별로 게임의 태그를 입력합니다.
	// Sets the tags of a game for each language.
	function setGameDetails(
		uint gameId,
		string calldata language,
		string calldata tag1,
		string calldata tag2,
		string calldata tag3,
		string calldata tag4) external {
		
		// 게임의 배포자인 경우에만
		require(dplayStore.checkIsPublisher(msg.sender, gameId) == true);
		
		gameIdToLanguageToTags[gameId][language] = GameTags({
			tag1 : tag1,
			tag2 : tag2,
			tag3 : tag3,
			tag4 : tag4
		});
	}
	
	// 출시된 게임 ID들을 가져옵니다.
	// Gets the IDs of released games.
	function getReleasedGameIds() public view returns (uint[] memory) {
		
		uint gameCount = 0;
		
		for (uint i = 0; i < dplayStore.getGameCount(); i += 1) {
			
			(
				address publisher,
				bool isReleased,
				, // price
				, // gameURL
				, // isWebGame
				, // defaultLanguage
				, // createTime
				  // lastUpdateTime
			) = dplayStore.getGameInfo(i);
			
			if (
			// 정상적인 게임 정보인지
			publisher != address(0x0) &&
			
			// 출시가 되었는지
			isReleased == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint j = 0;
		
		for (uint i = 0; i < dplayStore.getGameCount(); i += 1) {
			
			(
				address publisher,
				bool isReleased,
				, // price
				, // gameURL
				, // isWebGame
				, // defaultLanguage
				, // createTime
				  // lastUpdateTime
			) = dplayStore.getGameInfo(i);
			
			if (
			// 정상적인 게임 정보인지
			publisher != address(0x0) &&
			
			// 출시가 되었는지
			isReleased == true) {
				
				gameIds[j] = i;
				j += 1;
			}
		}
		
		return gameIds;
	}
	
	// 게임 ID들을 최신 순으로 가져옵니다.
	// Gets game IDs and sort them in the chronological order.
	function getGameIdsNewest() external view returns (uint[] memory) {
		
		uint[] memory publishedGameIds = getPublishedGameIds();
		
		uint[] memory gameIds = new uint[](publishedGameIds.length);
		uint j = 0;
		
		for (uint i = publishedGameIds.length - 1; i >= 0; i -= 1) {
			gameIds[j] = publishedGameIds[i];
			j += 1;
		}
		
		return gameIds;
	}
	
	// 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	// Gets game IDs, exclude the games with the low number of ratings and sort the unexcluded games in the descending rating order.
	function getGameIdsByRating(uint ratingCount) external view returns (uint[] memory) {
		
		uint[] memory publishedGameIds = getPublishedGameIds();
		
		uint gameCount = 0;
		
		for (uint i = 0; i < publishedGameIds.length; i += 1) {
			
			// 평가 수가 ratingCount 이상인 경우에만
			// The number of ratings must be higher than ratingCount.
			if (dplayStore.getRatingCount(publishedGameIds[i]) >= ratingCount) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint gameIdCount = 0;
		
		for (uint i = 0; i < publishedGameIds.length; i += 1) {
			
			// 평가 수가 ratingCount 이상인 경우에만
			// The number of ratings must be higher than ratingCount.
			if (dplayStore.getRatingCount(publishedGameIds[i]) >= ratingCount) {
				
				uint rating = dplayStore.getOverallRating(publishedGameIds[i]);
				
				uint j = gameIdCount;
				for (; j > 0; j -= 1) {
					if (dplayStore.getOverallRating(gameIds[j]) <= rating) {
						gameIds[j] = gameIds[j - 1];
					} else {
						break;
					}
				}
				
				gameIds[j] = i;
				gameIdCount += 1;
			}
		}
		
		return gameIds;
	}
	
	function checkAreSameString(string memory str1, string memory str2) internal pure returns (bool) {
		return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
	}
	
	function checkTag(uint gameId, string memory language, string memory tag) internal view returns (bool) {
		
		(
			, // publisher
			, // isPublished
			, // price
			, // gameURL
			, // isWebGame
			string memory defaultLanguage,
			, // createTime
			  // lastUpdateTime
		) = dplayStore.getGameInfo(gameId);
		
		GameTags memory gameTags = gameIdToLanguageToTags[gameId][language];
		GameTags memory defaultLanguageGameTags = gameIdToLanguageToTags[gameId][defaultLanguage];
		
		return
			checkAreSameString(gameTags.tag1, tag) == true ||
			checkAreSameString(gameTags.tag2, tag) == true ||
			checkAreSameString(gameTags.tag3, tag) == true ||
			checkAreSameString(gameTags.tag4, tag) == true ||
			checkAreSameString(defaultLanguageGameTags.tag1, tag) == true ||
			checkAreSameString(defaultLanguageGameTags.tag2, tag) == true ||
			checkAreSameString(defaultLanguageGameTags.tag3, tag) == true ||
			checkAreSameString(defaultLanguageGameTags.tag4, tag) == true;
	}
	
	// 태그에 해당하는 게임 ID들을 최신 순으로 가져옵니다.
	// Gets Game IDs based on the tags and sort them in the chronological order.
	function getGameIdsByTagNewest(string calldata language, string calldata tag) external view returns (uint[] memory) {
		
		uint[] memory publishedGameIds = getPublishedGameIds();
		
		uint gameCount = 0;
		
		for (uint i = publishedGameIds.length - 1; i >= 0; i -= 1) {
			
			// 태그에 해당하는지
			// Checks if the game's related to the tags.
			if (checkTag(publishedGameIds[i], language, tag) == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint j = 0;
		
		for (uint i = publishedGameIds.length - 1; i >= 0; i -= 1) {
			
			// 태그에 해당하는지
			// Checks if the game's related to the tags.
			if (checkTag(publishedGameIds[i], language, tag) == true) {
				
				gameIds[j] = publishedGameIds[i];
				j += 1;
			}
		}
		
		return gameIds;
	}
	
	// 태그에 해당하는 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	// Get game IDs based on the tags, exclude the games with the low number of ratings and sort the unexcluded games in the descending rating order.
	function getGameIdsByTagAndRating(string calldata language, string calldata tag, uint ratingCount) external view returns (uint[] memory) {
		
		uint[] memory publishedGameIds = getPublishedGameIds();
		
		uint gameCount = 0;
		
		for (uint i = 0; i < publishedGameIds.length; i += 1) {
			
			if (
			// 평가 수가 ratingCount 이상인 경우에만
			// The number of ratings should be higher than ratingCount.
			dplayStore.getRatingCount(publishedGameIds[i]) >= ratingCount &&
			
			// 태그에 해당하는지
			// Checks if the game's related to the tags.
			checkTag(publishedGameIds[i], language, tag) == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint gameIdCount = 0;
		
		for (uint i = 0; i < publishedGameIds.length; i += 1) {
			
			if (
			// 평가 수가 ratingCount 이상인 경우에만
			// The nuumber of ratings must be higher than ratingCount.
			dplayStore.getRatingCount(publishedGameIds[i]) >= ratingCount &&
			
			// 태그에 해당하는지
			// Checks if the game's related to the tags.
			checkTag(publishedGameIds[i], language, tag) == true) {
				
				uint rating = dplayStore.getOverallRating(publishedGameIds[i]);
				
				uint j = gameIdCount;
				for (; j > 0; j -= 1) {
					if (dplayStore.getOverallRating(gameIds[j]) <= rating) {
						gameIds[j] = gameIds[j - 1];
					} else {
						break;
					}
				}
				
				gameIds[j] = publishedGameIds[i];
				gameIdCount += 1;
			}
		}
		
		return gameIds;
	}
}
