// Code generated by mockery v1.0.1. DO NOT EDIT.

package mocks

import (
	context "context"

	service "github.com/flyteorg/flyteidl/gen/pb-go/flyteidl/service"
	mock "github.com/stretchr/testify/mock"
)

// DataProxyServiceServer is an autogenerated mock type for the DataProxyServiceServer type
type DataProxyServiceServer struct {
	mock.Mock
}

type DataProxyServiceServer_CreateUploadLocation struct {
	*mock.Call
}

func (_m DataProxyServiceServer_CreateUploadLocation) Return(_a0 *service.CreateUploadLocationResponse, _a1 error) *DataProxyServiceServer_CreateUploadLocation {
	return &DataProxyServiceServer_CreateUploadLocation{Call: _m.Call.Return(_a0, _a1)}
}

func (_m *DataProxyServiceServer) OnCreateUploadLocation(_a0 context.Context, _a1 *service.CreateUploadLocationRequest) *DataProxyServiceServer_CreateUploadLocation {
	c_call := _m.On("CreateUploadLocation", _a0, _a1)
	return &DataProxyServiceServer_CreateUploadLocation{Call: c_call}
}

func (_m *DataProxyServiceServer) OnCreateUploadLocationMatch(matchers ...interface{}) *DataProxyServiceServer_CreateUploadLocation {
	c_call := _m.On("CreateUploadLocation", matchers...)
	return &DataProxyServiceServer_CreateUploadLocation{Call: c_call}
}

// CreateUploadLocation provides a mock function with given fields: _a0, _a1
func (_m *DataProxyServiceServer) CreateUploadLocation(_a0 context.Context, _a1 *service.CreateUploadLocationRequest) (*service.CreateUploadLocationResponse, error) {
	ret := _m.Called(_a0, _a1)

	var r0 *service.CreateUploadLocationResponse
	if rf, ok := ret.Get(0).(func(context.Context, *service.CreateUploadLocationRequest) *service.CreateUploadLocationResponse); ok {
		r0 = rf(_a0, _a1)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*service.CreateUploadLocationResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *service.CreateUploadLocationRequest) error); ok {
		r1 = rf(_a0, _a1)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}
