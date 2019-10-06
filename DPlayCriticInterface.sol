pragma solidity ^0.5.9;

interface DPlayCriticInterface {
	
	// Events
	// 이벤트
    event Rate(uint indexed gameId, address indexed rater, uint rating, string review);
    event UpdateRating(uint indexed gameId, address indexed rater, uint rating, string review);
    event RemoveRating(uint indexed gameId, address indexed rater);
	
	// Rating info
	// 평가 정보
	struct Rating {
		address	rater;
		uint	rating;
		string	review;
	}
	
	function ratingDecimals() external view returns (uint8);
	
	// Rates a game.
	// 게임을 평가합니다.
	function rate(uint gameId, uint rating, string calldata review) external;
	
	// Checks if the given address is the rater's address.
	// 특정 주소가 평가자인지 확인합니다.
	function checkIsRater(address addr, uint gameId) external view returns (bool);
	
	// Gets the game IDs rated by the given rater.
	// 특정 평가자가 평가한 게임 ID들을 가져옵니다.
	function getRatedGameIds(address rater) external view returns (uint[] memory);
	
	// Returns the rating info of the given rater.
	// 특정 평가자가 내린 평가 정보를 반환합니다.
	function getRating(address rater, uint gameId) external view returns (uint rating, string memory review);
	
	// Updates a rating.
	// 평가를 수정합니다.
	function updateRating(uint gameId, uint rating, string calldata review) external;
	
	// Returns the number of ratings of a game.
	// 게임의 평가 수를 반환합니다.
	function getRatingCount(uint gameId) external view returns (uint);
	
	// Returns the overall rating of a game.
	// Overall rating = (The sum of all weighted ratings : Each rater's DC Power * Each rater's rating) / Sum of each rater's DC Power
	// 게임의 종합 평가 점수를 반환합니다.
	// 종합 평가 점수 = (모든 평가의 합: 평가자 A의 DC Power * 평가자 A의 평가 점수) / 모든 평가자의 DC Power
	function getOverallRating(uint gameId) external view returns (uint);
}
