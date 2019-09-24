# DPlay Store Search

## 계약 주소
- Kovan: 0x2aaF8692bc174b1C3C818dB5D3495d7974377F39

## 테스트 여부
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-yes-brightgreen.svg) `function setGameTags(uint gameId, string calldata language, string calldata tag1, string calldata tag2, string calldata tag3, string calldata tag4) external`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-yes-brightgreen.svg) `function getGameTags(uint gameId, string calldata language) external view returns (string memory tag1, string memory tag2, string memory tag3, string memory tag4)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-no-red.svg) `function getReleasedGameIds() external view returns (uint[] memory)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-yes-brightgreen.svg) `function getGameIdsNewest() external view returns (uint[] memory)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-no-red.svg) `function getGameIdsByRating(uint ratingCount) external view returns (uint[] memory)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-no-red.svg) `function getGameIdsByTagNewest(string calldata language, string calldata tag) external view returns (uint[] memory)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-no-red.svg) `function getGameIdsByTagAndRating(string calldata language, string calldata tag, uint ratingCount) external view returns (uint[] memory)`