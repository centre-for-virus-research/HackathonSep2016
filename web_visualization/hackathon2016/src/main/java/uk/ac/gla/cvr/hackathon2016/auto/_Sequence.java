package uk.ac.gla.cvr.hackathon2016.auto;

import org.apache.cayenne.CayenneDataObject;

/**
 * Class _Sequence was generated by Cayenne.
 * It is probably a good idea to avoid changing this class manually,
 * since it may be overwritten next time code is regenerated.
 * If you need to make any customizations, please use subclass.
 */
public abstract class _Sequence extends CayenneDataObject {

    public static final String LIB_PREP_PROPERTY = "libPrep";
    public static final String SEQ_ID_PROPERTY = "seqID";
    public static final String SEQ_TYPE_PROPERTY = "seqType";
    public static final String SMP_ID_PROPERTY = "smpID";
    public static final String TECHNOLOGY_PROPERTY = "technology";

    public static final String SEQ_ID_PK_COLUMN = "seqID";

    public void setLibPrep(String libPrep) {
        writeProperty(LIB_PREP_PROPERTY, libPrep);
    }
    public String getLibPrep() {
        return (String)readProperty(LIB_PREP_PROPERTY);
    }

    public void setSeqID(String seqID) {
        writeProperty(SEQ_ID_PROPERTY, seqID);
    }
    public String getSeqID() {
        return (String)readProperty(SEQ_ID_PROPERTY);
    }

    public void setSeqType(Short seqType) {
        writeProperty(SEQ_TYPE_PROPERTY, seqType);
    }
    public Short getSeqType() {
        return (Short)readProperty(SEQ_TYPE_PROPERTY);
    }

    public void setSmpID(Integer smpID) {
        writeProperty(SMP_ID_PROPERTY, smpID);
    }
    public Integer getSmpID() {
        return (Integer)readProperty(SMP_ID_PROPERTY);
    }

    public void setTechnology(String technology) {
        writeProperty(TECHNOLOGY_PROPERTY, technology);
    }
    public String getTechnology() {
        return (String)readProperty(TECHNOLOGY_PROPERTY);
    }

}
