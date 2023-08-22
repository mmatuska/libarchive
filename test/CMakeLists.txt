############################################
#
# How to build archivetest
#
############################################
IF(ENABLE_ARCHIVETEST)

  SET(archivetest_SOURCES
    archivetest.c
  )
  INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../libarchive_fe)

  # How to build archivetest
  ADD_EXECUTABLE(archivetest ${archivetest_SOURCES})
  IF(ENABLE_ARCHIVETEST_SHARED)
    TARGET_LINK_LIBRARIES(archivetest archive ${ADDITIONAL_LIBS})
  ELSE(ENABLE_ARCHIVETEST_SHARED)
    TARGET_LINK_LIBRARIES(archivetest archive_static ${ADDITIONAL_LIBS})
    SET_TARGET_PROPERTIES(archivetest PROPERTIES COMPILE_DEFINITIONS
                                 LIBARCHIVE_STATIC)
  ENDIF(ENABLE_ARCHIVETEST_SHARED)

  # Installation rules
  INSTALL(TARGETS archivetest RUNTIME DESTINATION bin)
  #INSTALL_MAN(${archivetest_MANS})
ENDIF(ENABLE_ARCHIVETEST)
