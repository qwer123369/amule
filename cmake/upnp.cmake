IF (BUILT_UPNP)
	EXTERNALPROJECT_ADD (UPNP
		GIT_REPOSITORY https://github.com/mrjimenez/pupnp.git
		GIT_TAG release-1.8.4
		GIT_PROGRESS TRUE
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND ""
	)

	EXTERNALPROJECT_GET_PROPERTY (UPNP SOURCE_DIR)
	SET (SEARCH_DIR_UPNP ${SOURCE_DIR} CACHE PATH "Search hint for libupnp library" FORCE)

	INSTALL (CODE
		"EXECUTE_PROCESS (
			COMMAND ${CMAKE_MAKE_PROGRAM} clean
			WORKING_DIRECTORY ${SOURCE_DIR}
		)

		EXECUTE_PROCESS (
			COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}
			WORKING_DIRECTORY ${SOURCE_DIR}
		)

		EXECUTE_PROCESS (
			COMMAND ${CMAKE_MAKE_PROGRAM} install
			WORKING_DIRECTORY ${SOURCE_DIR}
		)"
	)
ENDIF (BUILT_UPNP)

IF (SEARCH_DIR_UPNP)
	SET (PKG_CONFIG_USE_CMAKE_PREFIX_PATH TRUE)
	SET (CMAKE_PREFIX_PATH ${SEARCH_DIR_UPNP})
ENDIF (SEARCH_DIR_UPNP)

INCLUDE (FindPkgConfig)
PKG_CHECK_MODULES (LIBUPNP libupnp>=${MIN_UPNP_VERSION})
UNSET (CMAKE_PREFIX_PATH)

IF (NOT LIBUPNP_FOUND AND NOT DOWNLOAD_AND_BUILD_DEPS)
	SET (ENABLE_UPNP FALSE)
	MESSAGE (STATUS "lib-upnp not found or too old, disabling upnp")
ENDIF (NOT LIBUPNP_FOUND AND NOT DOWNLOAD_AND_BUILD_DEPS)

IF (NOT LIBUPNP_FOUND AND DOWNLOAD_AND_BUILD_DEPS AND WIN32)
	SET (ENABLE_UPNP FALSE)
	MESSAGE (STATUS "lib-upnp not found and automated building is not possible. Disabling")
ELSEIF (NOT LIBUPNP_FOUND AND DOWNLOAD_AND_BUILD_DEPS)
	EXTERNALPROJECT_ADD (UPNP
		GIT_REPOSITORY https://github.com/mrjimenez/pupnp.git
		GIT_TAG release-1.8.4
		GIT_PROGRESS TRUE
		PATCH_COMMAND ./bootstrap
		BUILD_IN_SOURCE TRUE
		CONFIGURE_COMMAND ./configure --prefix=<BINARY_DIR>
		BUILD_COMMAND ${CMAKE_MAKE_PROGRAM}
		INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
	)

	LIST (APPEND EXTERNAL_DEPS UPNP)
	SET (RECONF_COMMAND ${RECONF_COMMAND} -DBUILT_UPNP=TRUE CACHE INTERNAL "Command to redetect everything after external deps have been  built" FORCE)
ENDIF (NOT LIBUPNP_FOUND AND DOWNLOAD_AND_BUILD_DEPS AND WIN32)
