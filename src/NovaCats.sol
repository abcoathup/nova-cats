// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {IERC4883} from "./IERC4883.sol";
import {Base64} from "./Base64.sol";
import {Strings} from "./Strings.sol";

// 
// ░█▀█░█▀█░█░█░█▀█░░░█▀▀░█▀█░▀█▀░█▀▀
// ░█░█░█░█░▀▄▀░█▀█░░░█░░░█▀█░░█░░▀▀█
// ░▀░▀░▀▀▀░░▀░░▀░▀░░░▀▀▀░▀░▀░░▀░░▀▀▀
contract NovaCats is ERC721, Owned, IERC4883 {
    /// ERRORS

    /// @notice Thrown when supply cap reached
    error SupplyCapReached();

    /// @notice Thrown when token doesn't exist
    error NonexistentToken();

    /// EVENTS

    uint256 public totalSupply;
    uint256 public immutable supplyCap;

    string[] colors = [
        "AliceBlue",
        "AntiqueWhite",
        "Aqua",
        "Aquamarine",
        "Azure",
        "Beige",
        "Bisque",
        "Black",
        "BlanchedAlmond",
        "Blue",
        "BlueViolet",
        "Brown",
        "BurlyWood",
        "CadetBlue",
        "Chartreuse",
        "Chocolate",
        "Coral",
        "CornflowerBlue",
        "Cornsilk",
        "Crimson",
        "Cyan",
        "DarkBlue",
        "DarkCyan",
        "DarkGoldenRod",
        "DarkGreen",
        "DarkGrey",
        "DarkKhaki",
        "DarkMagenta",
        "DarkOliveGreen",
        "DarkOrange",
        "DarkOrchid",
        "DarkRed",
        "DarkSalmon",
        "DarkSeaGreen",
        "DarkSlateBlue",
        "DarkSlateGrey",
        "DarkTurquoise",
        "DarkViolet",
        "DeepPink",
        "DeepSkyBlue",
        "DimGrey",
        "DodgerBlue",
        "FireBrick",
        "FloralWhite",
        "ForestGreen",
        "Fuchsia",
        "Gainsboro",
        "GhostWhite",
        "Gold",
        "GoldenRod",
        "Green",
        "GreenYellow",
        "Grey",
        "HoneyDew",
        "HotPink",
        "IndianRed",
        "Indigo",
        "Ivory",
        "Khaki",
        "Lavender",
        "LavenderBlush",
        "LawnGreen",
        "LemonChiffon",
        "LightBlue",
        "LightCoral",
        "LightCyan",
        "LightGoldenRodYellow",
        "LightGreen",
        "LightGrey",
        "LightPink",
        "LightSalmon",
        "LightSeaGreen",
        "LightSkyBlue",
        "LightSlateGrey",
        "LightSteelBlue",
        "LightYellow",
        "Lime",
        "LimeGreen",
        "Linen",
        "Magenta",
        "Maroon",
        "MediumAquaMarine",
        "MediumBlue",
        "MediumOrchid",
        "MediumPurple",
        "MediumSeaGreen",
        "MediumSlateBlue",
        "MediumSpringGreen",
        "MediumTurquoise",
        "MediumVioletRed",
        "MidnightBlue",
        "MintCream",
        "MistyRose",
        "Moccasin",
        "NavajoWhite",
        "Navy",
        "OldLace",
        "Olive",
        "OliveDrab",
        "Orange",
        "OrangeRed",
        "Orchid",
        "PaleGoldenRod",
        "PaleGreen",
        "PaleTurquoise",
        "PaleVioletRed",
        "PapayaWhip",
        "PeachPuff",
        "Peru",
        "Pink",
        "Plum",
        "PowderBlue",
        "Purple",
        "RebeccaPurple",
        "Red",
        "RosyBrown",
        "RoyalBlue",
        "SaddleBrown",
        "Salmon",
        "SandyBrown",
        "SeaGreen",
        "SeaShell",
        "Sienna",
        "Silver",
        "SkyBlue",
        "SlateBlue",
        "SlateGrey",
        "Snow",
        "SpringGreen",
        "SteelBlue",
        "Tan",
        "Teal",
        "Thistle",
        "Tomato",
        "Turquoise",
        "Violet",
        "Wheat",
        "White",
        "WhiteSmoke",
        "Yellow",
        "YellowGreen"
    ];

    string[] personalities = ["Playful", "Friendly", "Curious", "Energetic", "Gentle", "Zazzy"];

    constructor() ERC721("Nova Cats", "CAT") Owned(0x13ebd3443fa5575F0Eb173e323D8419F7452CfB1) {
        supplyCap = 999;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4883).interfaceId || super.supportsInterface(interfaceId);
    }

    function mint() public {
        if (totalSupply >= supplyCap) {
            revert SupplyCapReached();
        }

        unchecked {
            totalSupply++;
        }

        _safeMint(msg.sender, totalSupply);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        ownerOf(tokenId);

        string memory tokenName_ = string.concat("Nova Cat #", Strings.toString(tokenId));
        string memory description =
            "Nova Cats. Cat emoji designed by OpenMoji (the open-source emoji and icon project). License: CC BY-SA 4.0";

        string memory image = _generateBase64Image(tokenId);
        string memory attributes = _generateAttributes(tokenId);
        return string.concat(
            "data:application/json;base64,",
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '{"name":"',
                        tokenName_,
                        '", "description":"',
                        description,
                        '", "image": "data:image/svg+xml;base64,',
                        image,
                        '",',
                        attributes,
                        "}"
                    )
                )
            )
        );
    }

    function _generateAttributes(uint256 tokenId) internal view returns (string memory) {
        string memory attributes = string.concat(
            '{"trait_type": "colour", "value": "',
            _generateColour(tokenId),
            '"}, {"trait_type": "personality", "value": "',
            _generatePersonality(tokenId),
            '"}'
        );

        return string.concat('"attributes": [', attributes, "]");
    }

    function _generateBase64Image(uint256 tokenId) internal view returns (string memory) {
        return Base64.encode(bytes(_generateSVG(tokenId)));
    }

    function _generateSVG(uint256 tokenId) internal view returns (string memory) {
        string memory svg = string.concat(
            '<svg id="',
            "novacat",
            Strings.toString(tokenId),
            '" viewBox="0 0 72 72" xmlns="http://www.w3.org/2000/svg">',
            renderTokenById(tokenId),
            "</svg>"
        );

        return svg;
    }

    function _generateColour(uint256 tokenId) internal view returns (string memory) {
        uint256 id = uint256(keccak256(abi.encodePacked("Colour", Strings.toString(tokenId))));
        id = id % colors.length;
        return colors[id];
    }

    function _generatePersonality(uint256 tokenId) internal view returns (string memory) {
        uint256 id = uint256(keccak256(abi.encodePacked("Colour", Strings.toString(tokenId))));
        id = id % personalities.length;
        return personalities[id];
    }

    function renderTokenById(uint256 tokenId) public view returns (string memory) {
        string memory colourValue = _generateColour(tokenId);

        return string.concat(
            '<g id="nounsglasses">' '<g id="color">' '<path fill="',
            colourValue,
            '" d="m47.25 44.38 2.658 2.696 5.591 1.245-1.291 4.058 0.75 3.218 2.208-0.7136 2.625-4.979 1.208-5.154c-1.059-1.656-2.403-3.314-3.157-4.998-1.79-1.403-2.502-3.671-3.718-5.915z"/>'
            '<path fill="',
            colourValue,
            '" d="m30.95 43.79-1.819 2.842-1.583 7.534-1.602 1.754-2.94-1.088-0.4713-4.959s0.822-4.787 1.322-6.823c0.5-2.036 5.149-2.382 5.149-2.382z"/>'
            '<path fill="',
            colourValue,
            '" d="m67.59 16.75-2.667-0.5572-4.29 1.557-0.7292 4.406-0.3746 3.141-3.25 3.822-2.645 1.549-1.761 0.0057c-0.0405-0.0547-0.0751-0.1098-0.1174-0.1643h-3.289l-5.323-2.035-5.971-2.086-9.892 0.5412-6.442 1.238-6.324-2.754-4.26-2.829-3.623 0.739 1.75 3.417-3.318 5.1 0.9412 4.237 5.09 0.1184 1.82 0.4315 3.396-1.197-0.2628 3.238 1.109 2.738-1.109 1.983-3.71 2.949-0.4855 4.093 2.798 3.289s3.938-0.3125 2.344-4.577l2.799-2.733 4.747-1.234 1.973-1.217 4.436 0.7886h8.409l2.13 3.404-1.424 4.683 0.0954 2.759 2.556-0.2704 2.948-3.93 1.937-2.57v-3.489l3.639-3.572 2.349-4.939s0.0198-0.1385 0.0331-0.3762l0.0119 0.0164s6.106-3.004 8.33-7.525c3.597-5.054-0.677-9.975 4.438-8.312 1.289 0.4189 2.75-2.25 1.187-3.875z"/>'
            "</g>"
            '<g id="line" fill="none" stroke="#000" stroke-linecap="round" stroke-linejoin="round" stroke-miterlimit="10" stroke-width="2">'
            '<path d="m12.46 35.74c-2.333 1-4.917 0.8333-4.917 0.8333-1.677 0.1458-3.115-4.01-2.485-4.733l3.318-5.1-1.75-3.417s5.008-1.415 7.883 2.09c0.3444 0.42 0.7943 0.7429 1.279 0.9871 0.0298 0.015 0.0602 0.0302 0.0912 0.0456 2.593 1.289 5.546 1.571 8.385 0.9981 7.222-1.458 14.07-1.37 21.7 2.212 7.625 3.583 14.83-2.25 13.94-7.5-0.793-4.647 3.562-7.583 6.75-5"/>'
            '<path d="m16.05 48.82c0.6006-2.206 8.491-3.648 8.491-3.648s3.228-1.201 1.426-4.504"/>'
            '<path d="m18.3 33.24c-1.543 1.834-3.893 4.803-0.44 9.158 0 0-6.756 2.853-6.006 8.033 0 0 0.3624 2.476 2.402 2.402"/>'
            '<path d="m23.5 50.03c-1.156 7.254 2.386 6.055 3.017 5.661 1.148-0.7173 1.848-9.854 3.952-11.31 1.592-1.104 8.167-0.3021 8.167-0.3021"/>'
            '<path d="m38.44 41.33c0.0911 1.742 0.7529 3.402 1.734 4.845 0.6616 0.9727 1.803 2.32 1.453 2.985-4.479 8.5 0.6224 7.022 1.083 6.167 3.188-5.917 6.125-4.104 4.647-10.52 0 0 5.27-1.81 5.52-7.977"/>'
            '<path d="m48.15 45.59s2.367 3.204 7.758 2.693c0 0-3.326 6.762 0 7.62 1.917 0.4941 4.722-11.16 4.722-11.16s-2.667-2.45-3.583-4.366"/>'
            "</g>" "</g>"
        );
    }
}
