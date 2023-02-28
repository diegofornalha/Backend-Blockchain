// Code generated by "stringer -type=Type"; DO NOT EDIT.

package transactions

import "strconv"

func _() {
	// An "invalid array index" compiler error signifies that the constant values have changed.
	// Re-run the stringer command to generate them again.
	var x [1]struct{}
	_ = x[Unknown-0]
	_ = x[General-1]
	_ = x[FtSetup-2]
	_ = x[FtTransfer-3]
	_ = x[NftSetup-4]
	_ = x[NftTransfer-5]
}

const _Type_name = "UnknownGeneralFtSetupFtTransferNftSetupNftTransfer"

var _Type_index = [...]uint8{0, 7, 14, 21, 31, 39, 50}

func (i Type) String() string {
	if i < 0 || i >= Type(len(_Type_index)-1) {
		return "Type(" + strconv.FormatInt(int64(i), 10) + ")"
	}
	return _Type_name[_Type_index[i]:_Type_index[i+1]]
}