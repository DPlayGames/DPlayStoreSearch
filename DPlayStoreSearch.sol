pragma solidity ^0.5.9;

import "./DPlayStoreSearchInterface.sol";
import "./DPlayStoreInterface.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DPlayStoreSearch is DPlayStoreSearchInterface, NetworkChecker {
	using SafeMath for uint;
	
	DPlayStoreInterface private dplayStore;
	
	constructor() NetworkChecker() public {
		
		// DPlay Store 스마트 계약을 불러옵니다.
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
	
	// 출시된 게임 ID들을 가져옵니다.
	function getPublishedGameIds() public view returns (uint[] memory) {
		
		uint gameCount = 0;
		
		for (uint i = 0; i < dplayStore.getGameCount(); i += 1) {
			
			(
				address publisher,
				bool isPublished,
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
			isPublished == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint j = 0;
		
		for (uint i = 0; i < dplayStore.getGameCount(); i += 1) {
			
			(
				address publisher,
				bool isPublished,
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
			isPublished == true) {
				
				gameIds[j] = i;
				j += 1;
			}
		}
		
		return gameIds;
	}
	
	// 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByRating(uint ratingCount) external view returns (uint[] memory) {
		
		uint[] memory publishedGameIds = getPublishedGameIds();
		
		uint gameCount = 0;
		
		for (uint i = 0; i < publishedGameIds.length; i += 1) {
			
			// 평가 수가 ratingCount 이상인 경우에만
			if (dplayStore.getRatingCount(publishedGameIds[i]) >= ratingCount) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint gameIdCount = 0;
		
		for (uint i = 0; i < publishedGameIds.length; i += 1) {
			
			// 평가 수가 ratingCount 이상인 경우에만
			if (dplayStore.getRatingCount(publishedGameIds[i]) >= ratingCount) {
				
				uint rating = dplayStore.getRating(publishedGameIds[i]);
				
				uint j = gameIdCount;
				for (; j > 0; j -= 1) {
					if (dplayStore.getRating(gameIds[j]) <= rating) {
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
	
	/*
	function checkAreSameString(string memory str1, string memory str2) internal pure returns (bool) {
		return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
	}
	
	function checkKeyword(uint gameId, string memory language, string memory keyword) internal view returns (bool) {
		
		Game memory game = games[gameId];
		
		GameDetails memory gameDetails = gameIdToLanguageToDetails[gameId][language];
		GameDetails memory defaultLanguageGameDetails = gameIdToLanguageToDetails[gameId][game.defaultLanguage];
		
		return
			checkAreSameString(gameDetails.keyword1, keyword) == true ||
			checkAreSameString(gameDetails.keyword2, keyword) == true ||
			checkAreSameString(gameDetails.keyword3, keyword) == true ||
			checkAreSameString(gameDetails.keyword4, keyword) == true ||
			checkAreSameString(gameDetails.keyword5, keyword) == true ||
			checkAreSameString(defaultLanguageGameDetails.keyword1, keyword) == true ||
			checkAreSameString(defaultLanguageGameDetails.keyword2, keyword) == true ||
			checkAreSameString(defaultLanguageGameDetails.keyword3, keyword) == true ||
			checkAreSameString(defaultLanguageGameDetails.keyword4, keyword) == true ||
			checkAreSameString(defaultLanguageGameDetails.keyword5, keyword) == true;
	}
	
	// 키워드에 해당하는 게임 ID들을 최신 순으로 가져옵니다.
	function getGameIdsByKeywordNewest(string calldata language, string calldata keyword) external view returns (uint[] memory) {
		
		uint gameCount = 0;
		
		for (uint i = 0; i < games.length; i += 1) {
			
			if (
			// 정상적인 게임 정보인지
			games[i].publisher != address(0x0) &&
			
			// 출시가 되었는지
			games[i].isPublished == true &&
			
			// 키워드에 해당하는지
			checkKeyword(i, language, keyword) == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint j = 0;
		
		for (uint i = games.length - 1; i >= 0; i -= 1) {
			
			if (
			// 정상적인 게임 정보인지
			games[i].publisher != address(0x0) &&
			
			// 출시가 되었는지
			games[i].isPublished == true &&
			
			// 키워드에 해당하는지
			checkKeyword(i, language, keyword) == true) {
				
				gameIds[j] = i;
				j += 1;
			}
		}
		
		return gameIds;
	}
	
	// 키워드에 해당하는 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByKeywordAndRating(string calldata language, string calldata keyword, uint ratingCount) external view returns (uint[] memory) {
		
		uint gameCount = 0;
		
		for (uint i = 0; i < games.length; i += 1) {
			
			if (
			// 정상적인 게임 정보인지
			games[i].publisher != address(0x0) &&
			
			// 출시가 되었는지
			games[i].isPublished == true &&
			
			// 평가 수가 ratingCount 이상인 경우에만
			gameIdToRatings[i].length >= ratingCount &&
			
			// 키워드에 해당하는지
			checkKeyword(i, language, keyword) == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint gameIdCount = 0;
		
		for (uint i = 0; i < games.length; i += 1) {
			
			if (
			// 정상적인 게임 정보인지
			games[i].publisher != address(0x0) &&
			
			// 출시가 되었는지
			games[i].isPublished == true &&
			
			// 평가 수가 ratingCount 이상인 경우에만
			gameIdToRatings[i].length >= ratingCount &&
			
			// 키워드에 해당하는지
			checkKeyword(i, language, keyword) == true) {
				
				uint rating = getRating(i);
				
				uint j = gameIdCount;
				for (; j > 0; j -= 1) {
					if (getRating(gameIds[j]) <= rating) {
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
	}*/
}