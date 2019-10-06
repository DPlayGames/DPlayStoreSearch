pragma solidity ^0.5.9;

import "./DPlayStoreSearchInterface.sol";
import "./DPlayStoreInterface.sol";
import "./DPlayCriticInterface.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DPlayStoreSearch is DPlayStoreSearchInterface, NetworkChecker {
	using SafeMath for uint;
	
	mapping(uint => mapping(string => GameTags)) private gameIdToLanguageToTags;
	
	DPlayStoreInterface private dplayStore;
	DPlayCriticInterface private dplayCritic;
	
	constructor() NetworkChecker() public {
		
		// Loads the smart contract of DPlay Store.
		// DPlay Store 스마트 계약을 불러옵니다.
		if (network == Network.Mainnet) {
			//TODO
		} else if (network == Network.Kovan) {
			dplayStore = DPlayStoreInterface(0x4d907141549bA4D311fEdDB3B0aDa6bA71587f27);
			dplayCritic = DPlayCriticInterface(0x9D787c1eD7e7b692D3a469670B75D3cfB5FbF352);
		} else if (network == Network.Ropsten) {
			//TODO
		} else if (network == Network.Rinkeby) {
			//TODO
		} else {
			revert();
		}
	}
	
	// Sets the tags of a game for each language.
	// 언어별로 게임의 태그들을 입력합니다.
	function setGameTags(
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
	
	// Gets the tags of the given game.
	// 게임의 태그들을 가져옵니다.
	function getGameTags(uint gameId, string calldata language) external view returns (
		string memory tag1,
		string memory tag2,
		string memory tag3,
		string memory tag4
	) {
		
		GameTags memory gameTags = gameIdToLanguageToTags[gameId][language];
		
		return (
			gameTags.tag1,
			gameTags.tag2,
			gameTags.tag3,
			gameTags.tag4
		);
	}
	
	// Gets the IDs of released games.
	// 출시된 게임 ID들을 가져옵니다.
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
				, // lastUpdateTime
				// releaseTime
			) = dplayStore.getGameInfo(i);
			
			if (
			// Checks if the game info is normal.
			// 정상적인 게임 정보인지
			publisher != address(0x0) &&
			
			// Checks if it's released.
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
				, // lastUpdateTime
				// releaseTime
			) = dplayStore.getGameInfo(i);
			
			if (
			// Checks if the game info is normal.
			// 정상적인 게임 정보인지
			publisher != address(0x0) &&
			
			// Checks if it's released.
			// 출시가 되었는지
			isReleased == true) {
				
				gameIds[j] = i;
				j += 1;
			}
		}
		
		return gameIds;
	}
	
	// Gets game IDs and sort by the release date.
	// 게임 ID들을 출시 순으로 가져옵니다.
	function getGameIdsNewest() external view returns (uint[] memory) {
		
		uint[] memory releasedGameIds = getReleasedGameIds();
		
		uint[] memory gameIds = new uint[](releasedGameIds.length);
		uint gameIdCount = 0;
		
		for (uint i = 0; i < releasedGameIds.length; i += 1) {
			
			(
				, // publisher
				, // isReleased
				, // price
				, // gameURL
				, // isWebGame
				, // defaultLanguage
				, // createTime
				, // lastUpdateTime
				uint releaseTime
			) = dplayStore.getGameInfo(releasedGameIds[i]);
			
			uint j = gameIdCount;
			for (; j > 0; j -= 1) {
				
				(
					, // publisherW
					, // isReleased
					, // price
					, // gameURL
					, // isWebGame
					, // defaultLanguage
					, // createTime
					, // lastUpdateTime
					uint releaseTime2
				) = dplayStore.getGameInfo(gameIds[j]);
				
				if (releaseTime2 <= releaseTime) {
					gameIds[j] = gameIds[j - 1];
				} else {
					break;
				}
			}
			
			gameIds[j] = releasedGameIds[i];
			gameIdCount += 1;
		}
		
		return gameIds;
	}
		
	// Gets game IDs, exclude the games with the low number of ratings and sort the unexcluded games in the descending rating order.
	// 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByRating(uint ratingCount) external view returns (uint[] memory) {
		
		uint[] memory releasedGameIds = getReleasedGameIds();
		
		uint gameCount = 0;
		
		for (uint i = 0; i < releasedGameIds.length; i += 1) {
			
			// The number of ratings must be higher than ratingCount.
			// 평가 수가 ratingCount 이상인 경우에만
			if (dplayCritic.getRatingCount(releasedGameIds[i]) >= ratingCount) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint gameIdCount = 0;
		
		for (uint i = 0; i < releasedGameIds.length; i += 1) {
			
			// The number of ratings must be higher than ratingCount.
			// 평가 수가 ratingCount 이상인 경우에만
			if (dplayCritic.getRatingCount(releasedGameIds[i]) >= ratingCount) {
				
				uint rating = dplayCritic.getOverallRating(releasedGameIds[i]);
				
				uint j = gameIdCount;
				for (; j > 0; j -= 1) {
					if (dplayCritic.getOverallRating(gameIds[j]) <= rating) {
						gameIds[j] = gameIds[j - 1];
					} else {
						break;
					}
				}
				
				gameIds[j] = releasedGameIds[i];
				gameIdCount += 1;
			}
		}
		
		return gameIds;
	}
		
	// 웹 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getWebGameIdsByRating(uint ratingCount) external view returns (uint[] memory) {
		
		uint[] memory releasedGameIds = getReleasedGameIds();
		
		uint gameCount = 0;
		
		for (uint i = 0; i < releasedGameIds.length; i += 1) {
			
			(
				,
				,
				,
				,
				bool isWebGame,
				,
				,
				,
				
			) = dplayStore.getGameInfo(releasedGameIds[i]);
			
			// 웹 게임이고, 평가 수가 ratingCount 이상인 경우에만
			if (isWebGame == true && dplayCritic.getRatingCount(releasedGameIds[i]) >= ratingCount) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint gameIdCount = 0;
		
		for (uint i = 0; i < releasedGameIds.length; i += 1) {
			
			(
				,
				,
				,
				,
				bool isWebGame,
				,
				,
				,
				
			) = dplayStore.getGameInfo(releasedGameIds[i]);
			
			// 웹 게임이고, 평가 수가 ratingCount 이상인 경우에만
			if (isWebGame == true && dplayCritic.getRatingCount(releasedGameIds[i]) >= ratingCount) {
				
				uint rating = dplayCritic.getOverallRating(releasedGameIds[i]);
				
				uint j = gameIdCount;
				for (; j > 0; j -= 1) {
					if (dplayCritic.getOverallRating(gameIds[j]) <= rating) {
						gameIds[j] = gameIds[j - 1];
					} else {
						break;
					}
				}
				
				gameIds[j] = releasedGameIds[i];
				gameIdCount += 1;
			}
		}
		
		return gameIds;
	}
	
	function checkAreSameString(string memory str1, string memory str2) private pure returns (bool) {
		return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
	}
	
	function checkTag(uint gameId, string memory language, string memory tag) private view returns (bool) {
		
		(
			, // publisher
			, // isPublished
			, // price
			, // gameURL
			, // isWebGame
			string memory defaultLanguage,
			, // createTime
			, // lastUpdateTime
			// releaseTime
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
	
	// Gets Game IDs based on the tags and sort by release date.
	// 태그에 해당하는 게임 ID들을 출시 순으로 가져옵니다.
	function getGameIdsByTagNewest(string calldata language, string calldata tag) external view returns (uint[] memory) {
		
		uint[] memory releasedGameIds = getReleasedGameIds();
		
		uint gameCount = 0;
		
		for (uint i = releasedGameIds.length; i > 0; i -= 1) {
			
			// Checks if the game's related to the tags.
			// 태그에 해당하는지
			if (checkTag(releasedGameIds[i - 1], language, tag) == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint gameIdCount = 0;
		
		for (uint i = 0; i < releasedGameIds.length; i += 1) {
			
			// Checks if the game's related to the tags.
			// 태그에 해당하는지
			if (checkTag(releasedGameIds[i - 1], language, tag) == true) {
				
				(
					, // publisher
					, // isReleased
					, // price
					, // gameURL
					, // isWebGame
					, // defaultLanguage
					, // createTime
					, // lastUpdateTime
					uint releaseTime
				) = dplayStore.getGameInfo(releasedGameIds[i]);
				
				uint j = gameIdCount;
				for (; j > 0; j -= 1) {
					
					(
						, // publisherW
						, // isReleased
						, // price
						, // gameURL
						, // isWebGame
						, // defaultLanguage
						, // createTime
						, // lastUpdateTime
						uint releaseTime2
					) = dplayStore.getGameInfo(gameIds[j]);
					
					if (releaseTime2 <= releaseTime) {
						gameIds[j] = gameIds[j - 1];
					} else {
						break;
					}
				}
				
				gameIds[j] = releasedGameIds[i];
				gameIdCount += 1;
			}
		}
		
		return gameIds;
	}
		
	// Get game IDs based on the tags, exclude the games with the low number of ratings and sort the unexcluded games in the descending rating order.
	// 태그에 해당하는 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByTagAndRating(string calldata language, string calldata tag, uint ratingCount) external view returns (uint[] memory) {
		
		uint[] memory releasedGameIds = getReleasedGameIds();
		
		uint gameCount = 0;
		
		for (uint i = 0; i < releasedGameIds.length; i += 1) {
			
			if (
			// The number of ratings should be higher than ratingCount.
			// 평가 수가 ratingCount 이상인 경우에만			
			dplayCritic.getRatingCount(releasedGameIds[i]) >= ratingCount &&
						
			// Checks if the game's related to the tags.
			// 태그에 해당하는지
			checkTag(releasedGameIds[i], language, tag) == true) {
				
				gameCount += 1;
			}
		}
		
		uint[] memory gameIds = new uint[](gameCount);
		uint gameIdCount = 0;
		
		for (uint i = 0; i < releasedGameIds.length; i += 1) {
			
			if (
			// The nuumber of ratings must be higher than ratingCount.
			// 평가 수가 ratingCount 이상인 경우에만
			dplayCritic.getRatingCount(releasedGameIds[i]) >= ratingCount &&
			
			// Checks if the game's related to the tags.
			// 태그에 해당하는지
			checkTag(releasedGameIds[i], language, tag) == true) {
				
				uint rating = dplayCritic.getOverallRating(releasedGameIds[i]);
				
				uint j = gameIdCount;
				for (; j > 0; j -= 1) {
					if (dplayCritic.getOverallRating(gameIds[j]) <= rating) {
						gameIds[j] = gameIds[j - 1];
					} else {
						break;
					}
				}
				
				gameIds[j] = releasedGameIds[i];
				gameIdCount += 1;
			}
		}
		
		return gameIds;
	}
}
