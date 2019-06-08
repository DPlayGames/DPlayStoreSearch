pragma solidity ^0.5.9;

import "./DPlayStoreSearchInterface.sol";
import "./DPlayStoreInterface.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DPlayStoreSearch is DPlayStoreSearchInterface, NetworkChecker {
	using SafeMath for uint;
	
	mapping(uint => mapping(string => GameKeywords)) private gameIdToLanguageToKeywords;
	
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
	
	// 언어별로 게임의 키워드를 입력합니다.
	function setGameDetails(
		uint gameId,
		string calldata language,
		string calldata keyword1,
		string calldata keyword2,
		string calldata keyword3,
		string calldata keyword4) external {
		
		// 게임의 배포자인 경우에만
		require(dplayStore.checkIsPublisher(msg.sender, gameId) == true);
		
		gameIdToLanguageToKeywords[gameId][language] = GameKeywords({
			keyword1 : keyword1,
			keyword2 : keyword2,
			keyword3 : keyword3,
			keyword4 : keyword4
		});
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
	
	function checkKeyword(uint gameId, string memory language, string memory keyword) internal view returns (bool) {
		
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
		
		GameKeywords memory gameKeywords = gameIdToLanguageToKeywords[gameId][language];
		GameKeywords memory defaultLanguageGameKeywords = gameIdToLanguageToKeywords[gameId][defaultLanguage];
		
		return
			checkAreSameString(gameKeywords.keyword1, keyword) == true ||
			checkAreSameString(gameKeywords.keyword2, keyword) == true ||
			checkAreSameString(gameKeywords.keyword3, keyword) == true ||
			checkAreSameString(gameKeywords.keyword4, keyword) == true ||
			checkAreSameString(defaultLanguageGameKeywords.keyword1, keyword) == true ||
			checkAreSameString(defaultLanguageGameKeywords.keyword2, keyword) == true ||
			checkAreSameString(defaultLanguageGameKeywords.keyword3, keyword) == true ||
			checkAreSameString(defaultLanguageGameKeywords.keyword4, keyword) == true;
	}
	
	// 키워드에 해당하는 게임 ID들을 최신 순으로 가져옵니다.
	function getGameIdsByKeywordNewest(string calldata language, string calldata keyword) external view returns (uint[] memory) {
		
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
			isPublished == true &&
			
			// 키워드에 해당하는지
			checkKeyword(i, language, keyword) == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint j = 0;
		
		for (uint i = dplayStore.getGameCount() - 1; i >= 0; i -= 1) {
			
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
			isPublished == true &&
			
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
			isPublished == true &&
			
			// 키워드에 해당하는지
			checkKeyword(i, language, keyword) == true &&
			
			// 평가 수가 ratingCount 이상인 경우에만
			dplayStore.getRatingCount(i) >= ratingCount &&
			
			// 키워드에 해당하는지
			checkKeyword(i, language, keyword) == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint gameIdCount = 0;
		
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
			isPublished == true &&
			
			// 키워드에 해당하는지
			checkKeyword(i, language, keyword) == true &&
			
			// 평가 수가 ratingCount 이상인 경우에만
			dplayStore.getRatingCount(i) >= ratingCount &&
			
			// 키워드에 해당하는지
			checkKeyword(i, language, keyword) == true) {
				
				uint rating = dplayStore.getOverallRating(i);
				
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
}